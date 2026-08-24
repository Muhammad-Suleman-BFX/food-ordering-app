// Thin JSON fetch wrapper for the food-ordering API.
// All /api endpoints return JSON; non-2xx responses carry { error, details }.

export class ApiError extends Error {
  constructor(message, status, details) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.details = details;
  }
}

export async function apiRequest(path, { method = "GET", body } = {}) {
  const options = {
    method,
    headers: { "Accept": "application/json" }
  };

  if (body !== undefined) {
    options.headers["Content-Type"] = "application/json";
    options.body = JSON.stringify(body);
  }

  let response;
  try {
    response = await fetch(path, options);
  } catch (networkError) {
    throw new ApiError("Network error. Please try again.", 0);
  }

  if (response.status === 204) {
    return null;
  }

  let payload = null;
  const contentType = response.headers.get("Content-Type") || "";
  if (contentType.includes("application/json")) {
    try {
      payload = await response.json();
    } catch (parseError) {
      payload = null;
    }
  }

  if (!response.ok) {
    const message = payload?.error || `Request failed with status ${response.status}`;
    throw new ApiError(message, response.status, payload?.details);
  }

  return payload;
}

export const api = {
  get: (path) => apiRequest(path),
  post: (path, body) => apiRequest(path, { method: "POST", body }),
  patch: (path, body) => apiRequest(path, { method: "PATCH", body }),
  delete: (path) => apiRequest(path, { method: "DELETE" })
};
