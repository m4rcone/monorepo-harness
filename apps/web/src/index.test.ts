import { describe, expect, it } from "vitest";
import { formatGreeting } from "./index.js";

describe("formatGreeting", () => {
  it("sauda pelo nome", () => {
    expect(formatGreeting("Ada")).toBe("Olá, Ada!");
  });
});
