export function renderTodos(todos) {
  return todos.map((todo, index) => `${index + 1}. ${todo.text}`).join("\n");
}
