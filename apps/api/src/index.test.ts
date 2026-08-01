import { describe, expect, it } from "vitest";
import { healthcheck } from "./index.js";

describe("healthcheck", () => {
  it("reporta ok", () => {
    expect(healthcheck().status).toBe("ok");
  });
});
