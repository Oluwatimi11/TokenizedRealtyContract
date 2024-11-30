import { describe, expect, it } from "vitest";

// Ensure that `simnet` is initialized correctly before accessing accounts
const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;

/*
  The test below is an example. To learn more, read the testing documentation here:
  https://docs.hiro.so/stacks/clarinet-js-sdk
*/

describe("example tests", () => {
  it("ensures simnet is well initialized", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("checks counter contract", async () => {
    // Ensure the simnet is up and running, and then query a contract for the counter value
    const { result } = await simnet.callReadOnlyFn("counter", "get-counter", [], address1);
    
    // Assert that the counter starts at 0
    expect(result).toBeUint(0);
  });
});

