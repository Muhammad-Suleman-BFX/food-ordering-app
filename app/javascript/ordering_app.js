// API-first food ordering SPA.
// Renders the customer flow by calling the /api JSON endpoints.
// Cart ID is stored in localStorage (no server session).
//
// Steps: start → menu → cart → confirm
// Both pickup and delivery support branch selection OR GPS nearest-branch.

import { api } from "api_client";

const CART_KEY = "food_ordering_cart_id";

const state = {
  step: "start", // start | menu | cart | confirm
  orderType: "pickup",
  selectedBranchId: "",
  branch: null,
  cart: null,
  order: null,
  error: null,
  notice: null,
  loading: false,
  menuItems: [],
  latitude: "",
  longitude: "",
  branches: []
};

function getApp() {
  return document.getElementById("app");
}

function setError(message) {
  state.error = message;
  state.notice = null;
  render();
}

function setNotice(message) {
  state.notice = message;
  state.error = null;
}

function clearMessages() {
  state.error = null;
  state.notice = null;
}

function setLoading(loading) {
  state.loading = loading;
  render();
}

function getCartId() {
  return localStorage.getItem(CART_KEY);
}

function setCartId(id) {
  if (id) {
    localStorage.setItem(CART_KEY, id);
  } else {
    localStorage.removeItem(CART_KEY);
  }
}

function money(value) {
  return "SAR " + Number(value).toFixed(2);
}

function escapeHtml(str) {
  const div = document.createElement("div");
  div.textContent = String(str);
  return div.innerHTML;
}

function resetOrderState() {
  setCartId(null);
  state.cart = null;
  state.branch = null;
  state.order = null;
  state.menuItems = [];
  state.selectedBranchId = "";
  state.latitude = "";
  state.longitude = "";
  state.step = "start";
}

// ── Views ──────────────────────────────────────────────

function renderMessages() {
  let html = "";
  if (state.error) {
    html += '<div class="flash flash-alert">' + escapeHtml(state.error) + "</div>";
  }
  if (state.notice) {
    html += '<div class="flash flash-notice">' + escapeHtml(state.notice) + "</div>";
  }
  return html;
}

function renderLoading() {
  return '<p style="text-align:center;color:#6b7280;">Loading…</p>';
}

function renderStart() {
  const isPickup = state.orderType === "pickup";
  const isDelivery = state.orderType === "delivery";

  const branchOptions = (state.branches || [])
    .map((b) => {
      const selected = String(state.selectedBranchId) === String(b.id) ? " selected" : "";
      return `<option value="${b.id}"${selected}>${escapeHtml(b.name)}</option>`;
    })
    .join("");

  return `
    <div class="card" style="text-align:center;padding:48px 28px;">
      <h1 style="margin-bottom:8px;">Start Your Order</h1>
      <p style="color:#6b7280;margin-bottom:32px;">
        Choose pickup or delivery, then select a branch or enter your GPS location.
      </p>

      <div class="form-group" style="text-align:left;">
        <label>Order Type</label>
        <div style="display:flex;gap:12px;margin-top:8px;">
          <label class="radio-card ${isPickup ? "radio-card-selected" : ""}">
            <input type="radio" name="order_type" value="pickup"
                   ${isPickup ? "checked" : ""}
                   onchange="orderingApp.setOrderType('pickup')">
            <span style="font-weight:500;">Pickup</span>
          </label>
          <label class="radio-card ${isDelivery ? "radio-card-selected" : ""}">
            <input type="radio" name="order_type" value="delivery"
                   ${isDelivery ? "checked" : ""}
                   onchange="orderingApp.setOrderType('delivery')">
            <span style="font-weight:500;">Delivery</span>
          </label>
        </div>
      </div>

      <div class="form-group" style="text-align:left;margin-top:24px;">
        <label for="branch-select">Select Branch</label>
        <select id="branch-select" onchange="orderingApp.selectBranch(this.value)">
          <option value="">Choose a branch…</option>
          ${branchOptions}
        </select>
      </div>

      <div style="display:flex;align-items:center;gap:12px;margin:24px 0;">
        <div style="flex:1;height:1px;background:#e5e7eb;"></div>
        <span style="color:#9ca3af;font-size:13px;font-weight:500;">OR</span>
        <div style="flex:1;height:1px;background:#e5e7eb;"></div>
      </div>

      <div class="form-group" style="text-align:left;">
        <label>GPS Location</label>
        <p style="color:#6b7280;font-size:13px;margin:4px 0 12px;">
          Enter latitude and longitude to use the nearest branch.
        </p>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
          <div>
            <label for="latitude" style="font-size:12px;">Latitude</label>
            <input id="latitude" type="number" step="any" placeholder="e.g. 21.4858"
                   value="${escapeHtml(state.latitude)}"
                   oninput="orderingApp.setCoordinates(this.value, document.getElementById('longitude').value)">
          </div>
          <div>
            <label for="longitude" style="font-size:12px;">Longitude</label>
            <input id="longitude" type="number" step="any" placeholder="e.g. 39.1925"
                   value="${escapeHtml(state.longitude)}"
                   oninput="orderingApp.setCoordinates(document.getElementById('latitude').value, this.value)">
          </div>
        </div>
        <button type="button" class="btn btn-secondary" style="margin-top:12px;"
                onclick="orderingApp.useMyLocation()">Use my location</button>
      </div>

      <div style="margin-top:28px;">
        <button class="btn btn-primary" style="padding:12px 32px;font-size:15px;"
                onclick="orderingApp.startOrder()">Browse Menu →</button>
      </div>
    </div>
  `;
}

function renderMenu() {
  const branch = state.branch;
  if (!branch) return renderStart();

  const items = state.menuItems || [];
  const list = items.length
    ? '<ul class="menu-list">' + items.map((item) => {
        const available = item.available !== false;
        const action = available
          ? `<button class="btn btn-primary" style="white-space:nowrap;flex-shrink:0;"
                     onclick="orderingApp.addItem(${item.id})">Add to cart</button>`
          : `<span class="badge" style="flex-shrink:0;opacity:0.7;">Unavailable</span>`;

        return `
          <li>
            <div style="padding:16px 20px;display:flex;align-items:center;justify-content:space-between;gap:16px;${available ? "" : "opacity:0.65;"}">
              <div style="flex:1;min-width:0;">
                <span class="list-primary">${escapeHtml(item.name)}</span>
                ${item.description ? '<span class="list-secondary" style="display:block;margin-top:2px;">' + escapeHtml(item.description) + "</span>" : ""}
                <span class="list-meta" style="margin-top:4px;">${money(item.price)}</span>
              </div>
              ${action}
            </div>
          </li>
        `;
      }).join("") + "</ul>"
    : '<div class="empty-state"><p>No items available at this branch right now.</p></div>';

  const orderTypeLabel = state.cart?.order_type || state.orderType;

  return `
    <div class="page-header" style="justify-content:space-between;">
      <button class="btn btn-secondary" onclick="orderingApp.changeBranch()">← Change</button>
      <button class="btn btn-primary" onclick="orderingApp.viewCart()">
        Cart (${state.cart?.total_items_count || 0})
      </button>
    </div>
    <h1 style="margin-bottom:8px;">${escapeHtml(branch.name)}</h1>
    <p style="color:#6b7280;margin-bottom:8px;">${escapeHtml(branch.address || "")}</p>
    <p style="color:#6b7280;margin-bottom:24px;font-size:13px;">
      Order type: <strong>${escapeHtml(orderTypeLabel)}</strong>
    </p>
    ${list}
  `;
}

function renderCart() {
  const cart = state.cart;
  if (!cart) return renderStart();

  const items = cart.items || [];
  const itemsHtml = items.length
    ? '<ul class="branch-list">' + items.map((item) => `
        <li>
          <div style="padding:16px 20px;">
            <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <span class="list-primary" style="flex:1;">${escapeHtml(item.name)}</span>
              <button class="btn btn-danger" style="padding:6px 12px;font-size:12px;"
                      onclick="orderingApp.removeItem(${item.id})">Remove</button>
            </div>
            <div style="display:flex;align-items:center;justify-content:space-between;margin-top:8px;">
              <div style="display:flex;align-items:center;gap:8px;">
                <input id="qty-${item.id}" type="number" min="1" value="${item.quantity}"
                       style="width:60px;padding:6px 10px;font-size:14px;">
                <button class="btn btn-secondary" style="padding:6px 12px;font-size:12px;"
                        onclick="orderingApp.updateItem(${item.id}, document.getElementById('qty-${item.id}').value)">
                  Update
                </button>
              </div>
              <span class="list-meta">${money(item.line_total)}</span>
            </div>
          </div>
        </li>
      `).join("") + "</ul>"
    : '<div class="empty-state"><p>Your cart is empty. Add items from the menu.</p></div>';

  const cartBranchName = cart.branch_name
    ? escapeHtml(cart.branch_name)
    : (state.branch ? escapeHtml(state.branch.name) : "Branch");

  return `
    <div style="display:flex;justify-content:space-between;margin-bottom:20px;gap:12px;flex-wrap:wrap;">
      <button class="btn btn-secondary" onclick="orderingApp.backToMenu()">← Back to Menu</button>
      <button class="btn btn-danger" onclick="orderingApp.clearCart()">Start Over</button>
    </div>
    <div class="card">
      <h1>Your Cart</h1>
      <div class="detail-grid">
        <div class="detail-item"><label>Branch</label><span>${cartBranchName}</span></div>
        <div class="detail-item"><label>Type</label><span>${escapeHtml(cart.order_type || "")}</span></div>
        <div class="detail-item"><label>Items</label><span>${cart.total_items_count}</span></div>
      </div>
    </div>
    ${itemsHtml}
    ${items.length ? `
      <div class="card" style="margin-top:24px;display:flex;align-items:center;justify-content:space-between;">
        <span style="font-size:18px;font-weight:700;">Total</span>
        <span style="font-size:22px;font-weight:700;">${money(cart.total_price)}</span>
      </div>
      <div style="margin-top:20px;">
        <button class="btn btn-primary" style="font-size:16px;width:100%;justify-content:center;"
                onclick="orderingApp.checkout()">Place Order →</button>
      </div>
    ` : ""}
  `;
}

function renderConfirmation() {
  const order = state.order;
  if (!order) return renderStart();

  const items = order.order_items || [];
  const itemsHtml = items.map((item) => {
    const lineTotal = Number(item.menu_item_price) * Number(item.menu_item_quantity);
    return `
      <li>
        <div style="padding:16px 20px;">
          <span class="list-primary">${escapeHtml(item.menu_item_name)}</span>
          <span class="list-secondary"> — ${item.menu_item_quantity} × ${money(item.menu_item_price)}</span>
          <span class="list-meta"> — ${money(lineTotal)}</span>
        </div>
      </li>
    `;
  }).join("");

  const totalItems = items.reduce((sum, i) => sum + Number(i.menu_item_quantity), 0);

  return `
    <div class="card">
      <h1 style="text-align:center;margin-bottom:8px;">Order Confirmed</h1>
      <p style="text-align:center;color:#6b7280;margin-bottom:28px;">Order #${order.id}</p>
      <div class="detail-grid">
        <div class="detail-item"><label>Type</label><span>${escapeHtml(order.order_type)}</span></div>
        <div class="detail-item"><label>Status</label><span class="badge badge-available">${escapeHtml(order.status)}</span></div>
        <div class="detail-item"><label>Items</label><span>${totalItems}</span></div>
        <div class="detail-item"><label>Total</label><span style="font-weight:700;">${money(order.total_price)}</span></div>
      </div>
    </div>
    <h2 style="margin-top:28px;margin-bottom:16px;">Ordered Items</h2>
    <ul class="branch-list">${itemsHtml}</ul>
    <div style="margin-top:20px;">
      <button class="btn btn-primary" style="width:100%;justify-content:center;"
              onclick="orderingApp.startOver()">Start New Order</button>
    </div>
  `;
}

function render() {
  let content;
  if (state.loading) {
    content = renderLoading();
  } else if (state.step === "confirm" && state.order) {
    content = renderConfirmation();
  } else if (state.step === "cart" && state.cart) {
    content = renderCart();
  } else if (state.step === "menu" && state.branch) {
    content = renderMenu();
  } else {
    content = renderStart();
  }

  const appEl = getApp();
  if (appEl) {
    appEl.innerHTML = renderMessages() + content;
  }
}

// ── Actions ────────────────────────────────────────────

async function loadBranches() {
  try {
    state.branches = await api.get("/api/branches");
    render();
  } catch (error) {
    setError(error.message);
  }
}

function syncStartFormFromDom() {
  const select = document.getElementById("branch-select");
  if (select) {
    state.selectedBranchId = select.value || "";
  }

  const latInput = document.getElementById("latitude");
  const lngInput = document.getElementById("longitude");
  if (latInput) state.latitude = latInput.value;
  if (lngInput) state.longitude = lngInput.value;
}

async function resolveBranchForOrder() {
  const branchId = String(state.selectedBranchId || "").trim();
  if (branchId) {
    const branch = state.branches.find((b) => String(b.id) === branchId);
    if (!branch) {
      throw new Error("Selected branch was not found.");
    }
    return branch;
  }

  const lat = String(state.latitude).trim();
  const lng = String(state.longitude).trim();
  if (!lat || !lng) {
    throw new Error("Please select a branch or enter both latitude and longitude.");
  }

  return api.get(`/api/branches/nearest?latitude=${encodeURIComponent(lat)}&longitude=${encodeURIComponent(lng)}`);
}

async function startOrder() {
  // Capture form values before loading re-render removes the DOM inputs.
  syncStartFormFromDom();
  clearMessages();
  setLoading(true);
  try {
    const branch = await resolveBranchForOrder();
    const cart = await api.post("/api/carts", {
      cart: { branch_id: branch.id, order_type: state.orderType }
    });
    setCartId(cart.id);
    state.cart = cart;
    state.branch = branch;
    state.cart.branch_name = branch.name;
    state.menuItems = await api.get("/api/branches/" + branch.id + "/menu");
    state.step = "menu";
    setNotice("Cart started at " + branch.name + ". Browse the menu and add items.");
  } catch (error) {
    setError(error.message);
  } finally {
    setLoading(false);
  }
}

async function refreshCartAndMenu() {
  const cartId = getCartId();
  if (!cartId) return;

  const cart = await api.get("/api/carts/" + cartId);
  state.cart = cart;

  let branch = state.branch;
  if (!branch || branch.id !== cart.branch_id) {
    if (!state.branches.length) {
      state.branches = await api.get("/api/branches");
    }
    branch = state.branches.find((b) => b.id === cart.branch_id) || { id: cart.branch_id, name: "", address: "" };
  }
  state.branch = branch;
  state.cart.branch_name = cart.branch_name || branch.name;
  state.orderType = cart.order_type || state.orderType;
  state.menuItems = await api.get("/api/branches/" + cart.branch_id + "/menu");
}

async function addItem(branchMenuItemId) {
  const cartId = getCartId();
  if (!cartId) return;
  clearMessages();
  setLoading(true);
  try {
    await api.post("/api/carts/" + cartId + "/items", { branch_menu_item_id: branchMenuItemId });
    await refreshCartAndMenu();
    state.step = "menu";
    setNotice("Item added to cart.");
  } catch (error) {
    setError(error.message);
  } finally {
    setLoading(false);
  }
}

async function viewCart() {
  const cartId = getCartId();
  if (!cartId) return;
  clearMessages();
  setLoading(true);
  try {
    const cart = await api.get("/api/carts/" + cartId);
    state.cart = cart;
    if (!state.branch || state.branch.id !== cart.branch_id) {
      if (!state.branches.length) {
        state.branches = await api.get("/api/branches");
      }
      state.branch = state.branches.find((b) => b.id === cart.branch_id) || null;
    }
    if (state.branch && !state.cart.branch_name) {
      state.cart.branch_name = state.branch.name;
    }
    state.step = "cart";
  } catch (error) {
    setError(error.message);
  } finally {
    setLoading(false);
  }
}

async function backToMenu() {
  clearMessages();
  setLoading(true);
  try {
    await refreshCartAndMenu();
    state.step = "menu";
  } catch (error) {
    setError(error.message);
  } finally {
    setLoading(false);
  }
}

async function updateItem(itemId, quantity) {
  const cartId = getCartId();
  if (!cartId) return;
  clearMessages();
  setLoading(true);
  try {
    await api.patch("/api/carts/" + cartId + "/items/" + itemId, { quantity: Number(quantity) });
    const cart = await api.get("/api/carts/" + cartId);
    state.cart = cart;
    if (state.branch) {
      state.cart.branch_name = state.branch.name;
    }
    state.step = "cart";
    setNotice("Quantity updated.");
  } catch (error) {
    setError(error.message);
  } finally {
    setLoading(false);
  }
}

async function removeItem(itemId) {
  const cartId = getCartId();
  if (!cartId) return;
  clearMessages();
  setLoading(true);
  try {
    await api.delete("/api/carts/" + cartId + "/items/" + itemId);
    const cart = await api.get("/api/carts/" + cartId);
    state.cart = cart;
    if (state.branch) {
      state.cart.branch_name = state.branch.name;
    }
    state.step = "cart";
    setNotice("Item removed from cart.");
  } catch (error) {
    setError(error.message);
  } finally {
    setLoading(false);
  }
}

async function checkout() {
  const cartId = getCartId();
  if (!cartId) return;
  clearMessages();
  setLoading(true);
  try {
    const order = await api.post("/api/carts/" + cartId + "/checkout");
    setCartId(null);
    state.cart = null;
    state.branch = null;
    state.menuItems = [];
    state.order = order;
    state.step = "confirm";
    setNotice("Order placed successfully!");
  } catch (error) {
    setError(error.message);
  } finally {
    setLoading(false);
  }
}

function changeBranch() {
  resetOrderState();
  state.orderType = "pickup";
  clearMessages();
  render();
}

function clearCart() {
  resetOrderState();
  state.orderType = "pickup";
  clearMessages();
  setNotice("Cart cleared. Start a new order.");
  render();
}

function startOver() {
  resetOrderState();
  state.orderType = "pickup";
  clearMessages();
  render();
}

function setOrderType(type) {
  state.orderType = type;
  clearMessages();
  render();
}

function selectBranch(branchId) {
  state.selectedBranchId = branchId || "";
}

function setCoordinates(latitude, longitude) {
  state.latitude = latitude;
  state.longitude = longitude;
}

function useMyLocation() {
  clearMessages();
  if (!navigator.geolocation) {
    setError("Geolocation is not supported by this browser. Please enter coordinates manually.");
    return;
  }

  setLoading(true);
  navigator.geolocation.getCurrentPosition(
    (position) => {
      state.latitude = String(position.coords.latitude);
      state.longitude = String(position.coords.longitude);
      state.selectedBranchId = "";
      setLoading(false);
      setNotice("Location captured. Click Browse Menu to find the nearest branch.");
      render();
    },
    () => {
      setLoading(false);
      setError("Could not get your location. Please enter latitude and longitude manually.");
    },
    { enableHighAccuracy: true, timeout: 10000 }
  );
}

async function resumeExistingCart() {
  const cartId = getCartId();
  if (!cartId) return;

  try {
    await refreshCartAndMenu();
    state.step = "menu";
    render();
  } catch (_error) {
    resetOrderState();
    render();
  }
}

// ── Init ───────────────────────────────────────────────

export function init() {
  state.orderType = "pickup";
  state.step = "start";
  render();
  loadBranches().then(() => resumeExistingCart());
}

window.orderingApp = {
  setOrderType,
  selectBranch,
  setCoordinates,
  useMyLocation,
  startOrder,
  addItem,
  viewCart,
  backToMenu,
  updateItem,
  removeItem,
  checkout,
  changeBranch,
  clearCart,
  startOver
};
