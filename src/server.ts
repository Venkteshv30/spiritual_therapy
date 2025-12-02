import "dotenv/config";
import app from "./app";
import { PORT } from "./config/constants";
import prisma from "./config/database";

const startServer = async () => {
  try {
    await prisma.$connect();
    console.log("✅ Database connected");

    app.listen(PORT, () => {
      console.log(`🚀 Server: http://localhost:${PORT}`);
      console.log(`📚 Docs: http://localhost:${PORT}/api-docs`);
    });
  } catch (error) {
    console.error("❌ Failed to start:", error);
    process.exit(1);
  }
};

startServer();

process.on("SIGINT", async () => {
  await prisma.$disconnect();
  process.exit(0);
});
