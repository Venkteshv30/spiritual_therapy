import "dotenv/config";

export default {
  datasource: {
    provider: "postgresql",
    url:
      process.env.DATABASE_URL ||
      "postgresql://postgres:password@localhost:5432/spiritual_therapy?schema=public",
  },
};
