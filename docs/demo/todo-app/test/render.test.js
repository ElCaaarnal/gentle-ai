import assert from "node:assert/strict";
import test from "node:test";

import { renderTodos } from "../src/render.js";

test("renders the todo list wording", () => {
  const output = renderTodos([
    { text: "Buy milk", completed: true },
    { text: "Walk the dog", completed: false },
  ]);

  assert.equal(output, "1. Buy milk\n2. Walk the dog");
  assert.doesNotMatch(output, /Completed:/);
});
