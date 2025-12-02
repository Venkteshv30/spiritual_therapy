export function normalizeBigInt(obj: any): any {
  if (typeof obj === "bigint") return obj.toString();
  if (Array.isArray(obj)) return obj.map(normalizeBigInt);
  if (obj !== null && typeof obj === "object") {
    return Object.fromEntries(
      Object.entries(obj).map(([key, value]) => [key, normalizeBigInt(value)])
    );
  }
  return obj;
}
