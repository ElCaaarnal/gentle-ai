import assert from "node:assert/strict";
import test from "node:test";

import { createTodos } from "../src/todos.js";

test("creates the two demo todos", () => {
  assert.deepEqual(createTodos(), [
    { text: "Buy milk", completed: true },
    { text: "Walk the dog", completed: false },
  ]);
});
