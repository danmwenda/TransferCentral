const functions = require("firebase-functions");
const express = require("express");
const admin = require("firebase-admin");
const cheerio = require("cheerio");

admin.initializeApp();

const app = express();

const db = admin.firestore();
db.settings({ignoreUndefinedProperties: true});

app.get("/team-news/:teamName", async (req, res) => {
  const teamName = req.params.teamName;

  try {
    const articlesSnapshot = await db.collection(teamName).get();

    if (articlesSnapshot.empty) {
      res.status(404).json({error: "Team not found"});
      return;
    }

    const newsArticles = [];
    articlesSnapshot.forEach((article) => {
      newsArticles.push({
        title: article.data().title,
        source: article.data().source,
        url: article.data().url,
        urlToImage: article.data().urlToImage,
        publishedAt: article.data().publishedAt,
      });
    });

    res.json(newsArticles);
  } catch (error) {
    console.error("Failed to fetch news", error);
    res.status(500).json({error: "Failed to fetch news"});
  }
});

// Subscribe user to topics based on favorite teams
app.post("/subscribe-to-teams", async (req, res) => {
  const {token, favoriteTeams} = req.body;

  try {
    const messaging = admin.messaging();
    for (const team of favoriteTeams) {
      // Replace spaces with underscores
      const teamKey = team.replace(/ /g, "_");
      await messaging.subscribeToTopic(token, teamKey);
    }

    res.json({success: true});
  } catch (error) {
    console.error("Error subscribing to topics:", error);
    res.status(500).json({error: "Failed to subscribe to topics"});
  }
});

// Unsubscribe user from topics based on favorite teams
app.post("/unsubscribe-from-teams", async (req, res) => {
  const {token, favoriteTeams} = req.body;

  try {
    const messaging = admin.messaging();
    for (const team of favoriteTeams) {
      const teamKey = team.replace(/ /g, "_");
      await messaging.unsubscribeFromTopic(token, teamKey);
    }

    res.json({success: true});
  } catch (error) {
    console.error("Error unsubscribing from topics:", error);
    res.status(500).json({error: "Failed to unsubscribe from topics"});
  }
});

exports.api = functions.https.onRequest(app);


exports.fetchNews = functions.pubsub
    .schedule("0 */12 * * *")
    .timeZone("Africa/Nairobi")
    .onRun(async (context) => {
      const teamNames = [
        "Manchester United F.C.",
        "Manchester City F.C.",
        "Liverpool F.C.",
        "Chelsea F.C.",
        "Arsenal F.C.",
        "Tottenham Hotspur F.C.",
        "FC Barcelona",
        "Real Madrid CF",
        "Juventus F.C.",
        "A.C. Milan",
        "Inter Milan",
        "FC Bayern Munich",
        "Borussia Dortmund",
        "Paris Saint-Germain F.C.",
      ];

      for (const teamName of teamNames) {
        try {
          const url = `https://news.google.com/search?q=${teamName}`;
          const response = await fetch(url);
          const html = await response.text();
          const $ = cheerio.load(html);

          const articles = [];
          $("article").each((i, article) => {
            const title = $(article).find("h3").text();
            const publishedAt = $(article).find("time").attr("datetime");
            const urlToImage = $("article > figure").find("img").attr("srcset");
            const url = $(article).find("a").attr("href");
            const source = $("article > div").find("img").attr("src");

            articles.push({
              title: title,
              publishedAt: publishedAt,
              urlToImage: urlToImage,
              url: url,
              source: source,
            });
          });

          // Get the reference to the team's document
          const teamRef = db.collection(teamName);

          // Use pagination to add articles in smaller batches
          const batchSize = 50;
          for (let i = 0; i < articles.length; i += batchSize) {
            const batch = db.batch();
            const batchArticles = articles.slice(i, i + batchSize);

            for (const article of batchArticles) {
            // Check for duplicates based on the article's title
              const querySnapshot = await teamRef.where("title", "==",
                  article.title).get();

              if (querySnapshot.empty) {
                const newDocRef = teamRef.doc();
                batch.set(newDocRef, article);
              }
            }

            await batch.commit();
          }

          console.log(`News fetched and stored successfully for ${teamName}`);
        } catch (error) {
          console.error(`Error fetching and storing news for ${teamName}:`,
              error);
        }
      }
    });

exports.deleteOldArticles = functions.pubsub
    .schedule("0 0 * * 0")
    .timeZone("Africa/Nairobi")
    .onRun(async (context) => {
      try {
        const teamNames = [
          "Manchester United F.C.",
          "Manchester City F.C.",
          "Liverpool F.C.",
          "Chelsea F.C.",
          "Arsenal F.C.",
          "Tottenham Hotspur F.C.",
          "FC Barcelona",
          "Real Madrid CF",
          "Juventus F.C.",
          "A.C. Milan",
          "Inter Milan",
          "FC Bayern Munich",
          "Borussia Dortmund",
          "Paris Saint-Germain F.C.",
        ];

        for (const teamName of teamNames) {
          const articles = await db.collection(teamName).get();
          const now = Date.now();
          const twoWeeksAgo = now - 14 * 24 * 60 * 60 * 1000;

          for (const article of articles.docs) {
            const datetime = article.data().publishedAt;
            const articleDate = Date.parse(datetime);
            if (articleDate < twoWeeksAgo) {
              await db.collection(teamName).doc(article.id).delete();
            }
          }
          console.log(`Old articles deleted successfully for ${teamName}`);
        }

        return null;
      } catch (error) {
        console.error("Error deleting old articles:", error);
        return null;
      }
    });

// Cloud Function to send notification for new article
exports.sendNotification = functions.firestore
    .document("{teamName}/{articleId}")
    .onCreate(async (snapshot, context) => {
      try {
        const {teamName, articleId} = context.params;
        const article = snapshot.data();

        const payload = {
          notification: {
            title: `New Article for ${teamName}`,
            body: `Check out the latest article: ${article.title}`,
          },
          data: {
            articleId: articleId,
          },
        };

        const messaging = admin.messaging();
        const topic = teamName.replace(/ /g, "_");
        await messaging.sendToTopic(topic, payload);

        console.log("Notification sent successfully");
        return null;
      } catch (error) {
        console.error("Error sending notification:", error);
        return null;
      }
    });
