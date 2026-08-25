# Food Ordering App — API-First

A full-featured food ordering web application built with **Ruby on Rails 7.2**. The app is now **API-first**: all customer-facing interactions go through a JSON REST API, and the browser frontend is a lightweight JavaScript single-page application (SPA) that consumes those endpoints.

The app lets customers browse branch-specific menus, build a cart, and place pickup or delivery orders. It ships with seed data, including branch locations, menu items, carts, and orders.

## Architecture

```
┌──────────────────────┐         ┌──────────────────────────┐
│   Browser (SPA)      │  JSON   │   Rails API (app/api)    │
│  app/javascript/     │◀───────▶│  app/controllers/api/    │
│   ordering_app.js    │  HTTP   │   branches_controller    │
│   api_client.js      │         │   carts_controller       │
│                      │         │   cart_items_controller  │
└──────────────────────┘         └──────────────────────────┘
        ▲                                   │
        │  localStorage (cart id)           │  ActiveRecord
        ▼                                   ▼
   ┌──────────┐                     ┌──────────────┐
   │  Models  │                     │   Database   │
   │  (Branch,│                     │  PostgreSQL  │
   │   Cart…) │                     │              │
   └──────────┘                     └──────────────┘
```

- **API layer** — `app/controllers/api/` controllers inherit from `Api::BaseController` (an `ActionController::API` subclass). Every endpoint returns JSON with appropriate HTTP status codes and structured validation errors.
- **Frontend** — `app/javascript/ordering_app.js` is a dependency-free SPA that renders the 5-step ordering flow by calling the API. The cart ID is persisted in `localStorage`, so no server session is required.
- **Admin pages** — HTML CRUD pages for branches, menu items, branch menu items, and orders remain available for management.

## Features

- **Branch Management** — Manage restaurant branches with name, address, and GPS coordinates (latitude/longitude).
- **Menu Items** — Central catalog of menu items with a global `base_availability` flag.
- **Per-Branch Menus** — Each branch offers its own subset of menu items with branch-specific pricing and availability (`BranchMenuItem`).
- **Smart Branch Selection** — When ordering, customers can pick a branch manually or provide GPS coordinates to auto-detect the **nearest branch**.
- **Cart** — A cart is created via the API and its ID is stored in `localStorage`; items are validated to belong to the same branch.
- **Order Types** — Support for **Pickup** and **Delivery** orders.
- **Order Status Tracking** — Orders flow through `pending → confirmed → preparing → ready → out_for_delivery → completed` (or `cancelled`).
- **Price Snapshots** — Order items store a snapshot of the item name and price at the time of ordering, so later menu changes don't affect historical orders.
- **Validation & Business Rules** — Enforces availability rules, same-branch cart consistency, positive pricing, and prevents modification of cancelled orders.

## Tech Stack

| Layer        | Technology                                               |
|--------------|----------------------------------------------------------|
| Framework    | Ruby on Rails 7.2                                        |
| Language     | Ruby 3.4.2                                               |
| Database     | PostgreSQL with PostGIS (`activerecord-postgis-adapter`) |
| Frontend     | Vanilla JavaScript (Importmap) SPA                       |

## Getting Started

### Prerequisites

- **Ruby** 3.4.2 (see `.ruby-version`)
- **PostgreSQL** with the **PostGIS** extension enabled
- **Bundler**

### Installation

1. **Install dependencies**

   ```bash
   bundle install
   ```

2. **Set up the database**

   ```bash
   bin/rails db:create
   bin/rails db:migrate
   ```

3. **Load seed data**

   The seed file populates the database with Albaik KSA branches, menu items, branch menus, carts, and orders.

   ```bash
   bin/rails db:seed
   ```

4. **Start the server**

   ```bash
   bin/rails server
   ```

   Then open [http://localhost:3000](http://localhost:3000) in your browser.

## API Reference

All endpoints return JSON. Errors use the shape `{ "error": "...", "details": {...} }` with appropriate HTTP status codes.

### Branches

| Method | Path                          | Description                                                   |
|--------|-------------------------------|-----------------------------------------------------          |
| GET    | `/api/branches`               | List all branches.                                            |
| GET    | `/api/branches/nearest`       | Find nearest branch by `latitude` & `longitude` query params. |
| GET    | `/api/branches/:id/menu`      | List available menu items for a branch.                       |

### Carts

| Method | Path                          | Description                                            |
|--------|-------------------------------|-----------------------------------------------------   |
| POST   | `/api/carts`                  | Create a cart (`{ cart: { branch_id, order_type } }`). |
| GET    | `/api/carts/:id`              | Show a cart with items and totals.                     |
| POST   | `/api/carts/:id/checkout`     | Convert cart to an order; destroys the cart.           |

### Cart Items

| Method | Path                                       | Description                                                                      |
|--------|--------------------------------------------|-----------------------------------------------------                             |
| POST   | `/api/carts/:id/items`                     | Add an item (`{ branch_menu_item_id }`). Increments quantity if already present. |
| PATCH  | `/api/carts/:id/items/:item_id`            | Update quantity (`{ quantity }`).                                                |
| DELETE | `/api/carts/:id/items/:item_id`            | Remove an item from the cart.                                                    |

### Status Codes

| Code | Meaning                  | When                                                       |
|------|--------------------------|------------------------------------------------------------|
| 200  | OK                       | Successful GET / PATCH.                                    |
| 201  | Created                  | Successful POST (cart, item, checkout).                    |
| 204  | No Content               | Successful DELETE.                                         |
| 400  | Bad Request              | Missing required params (e.g. coordinates).                |
| 404  | Not Found                | Record not found (branch, cart, or cart item).             |
| 422  | Unprocessable Entity     | Validation error or business-rule violation.               |

## Customer Ordering Flow

The browser SPA (`app/javascript/ordering_app.js`) drives the full flow through the API:

1. **Start** — The customer chooses **Pickup** or **Delivery**, then either selects a branch **or** enters GPS coordinates (or uses browser geolocation). If GPS is used, the app calls `GET /api/branches/nearest`.
2. **Create Cart** — `POST /api/carts` creates a cart for the resolved branch; the cart ID is saved to `localStorage`.
3. **Browse Menu** — `GET /api/branches/:id/menu` returns available items; the customer adds items via `POST /api/carts/:id/items`. Unavailable items cannot be added.
4. **Review Cart** — `GET /api/carts/:id` shows items, quantities, line totals, and the cart total. Quantities are adjusted with `PATCH` and items removed with `DELETE`.
5. **Checkout** — `POST /api/carts/:id/checkout` creates an order (with price snapshots) and destroys the cart. The confirmation screen shows the order number, status, and items.

## Project Structure

### Models & Relationships

```
Branch ──┬── has_many :branch_menu_items ──┬── belongs_to :menu_item (MenuItem)
         │                                 └── has_many :cart_items
         ├── has_many :menu_items (through :branch_menu_items)
         ├── has_many :carts ──┬── has_many :cart_items ── belongs_to :branch_menu_item
         └── has_many :orders ─┴── has_many :order_items
```

| Model             | Purpose                                                                |
|-------------------|------------------------------------------------------------------------|
| `Branch`          | A restaurant location with address and GPS coordinates.                |
| `MenuItem`        | A catalog item with a global base availability flag.                   |
| `BranchMenuItem`  | Links a menu item to a branch with branch-specific price/availability. |
| `Cart`            | A cart tied to a single branch with an `order_type` (pickup/delivery). |
| `CartItem`        | A line item in a cart referencing a `BranchMenuItem`.                  |
| `Order`           | A placed order with type (pickup/delivery) and status.                 |
| `OrderItem`       | A snapshot line item of an order (name, price, quantity).              |

### Key Routes

| Method | Path                            | Action                        |
|--------|---------------------------------|-------------------------------|
| GET    | `/`                             | SPA shell (customer ordering) |
| GET    | `/api/branches`                 | List branches (JSON)          |
| GET    | `/api/branches/:id/menu`        | Branch menu (JSON)            |
| POST   | `/api/carts`                    | Create cart (JSON)            |
| GET    | `/api/carts/:id`                | Show cart (JSON)              |
| POST   | `/api/carts/:id/checkout`       | Place order (JSON)            |
| POST   | `/api/carts/:id/items`          | Add cart item (JSON)          |
| PATCH  | `/api/carts/:id/items/:item_id` | Update cart item (JSON)       |
| DELETE | `/api/carts/:id/items/:item_id` | Remove cart item (JSON)       |

## Testing

Run the test suite with:

```bash
bin/rails test
```

The API is covered by request tests in `test/controllers/api/` and end-to-end API ordering flows in `test/integration/api_ordering_flow_test.rb`.

## Assumptions and Design Decisions

- **API-first customer path** — Customer ordering uses JSON endpoints and a lightweight SPA. There is no server-session cart flow. HTML pages are admin-only (branches, menu items, branch menus, order history).
- **Stateless carts** — Cart IDs are stored in `localStorage` rather than server sessions so the SPA does not depend on cookies.
- **Nearest branch** — Delivery uses a simple absolute lat/lng distance ranking for the nearest-branch lookup (sufficient for this dataset size).
- **Price snapshots** — `OrderItem` stores name and price at checkout so later menu edits do not change historical orders.
- **Availability** — An item must be available both globally (`MenuItem#base_availability`) and at the branch (`BranchMenuItem#menu_item_availability`) to be ordered.
- **Order type on cart** — `order_type` is chosen up front and copied onto the `Order` at checkout.