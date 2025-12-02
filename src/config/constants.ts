export const PORT = process.env.PORT || 3000;
export const NODE_ENV = process.env.NODE_ENV || "development";
export const AUTH_ENABLED = process.env.AUTH_ENABLED === "true";

export const MEMBERSHIP_LIMITS = {
  FREE: { sessionsPerMonth: 2 },
  SILVER: { sessionsPerMonth: 4 },
  GOLD: { sessionsPerMonth: 10 },
  PREMIUM: { sessionsPerMonth: -1 },
};
