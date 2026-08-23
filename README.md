# Food Ordering App

A full-featured food ordering web application built with **Ruby on Rails 7.2**. The app lets customers browse branch-specific menus, build a cart, and place pickup or delivery orders. It ships with seed data, including branch locations, menu items, carts, and orders.

## Features

- **Branch Management** — Manage restaurant branches with name, address, and GPS coordinates (latitude/longitude).
- **Menu Items** — Central catalog of menu items with a global `base_availability` flag.
- **Per-Branch Menus** — Each branch offers its own subset of menu items with branch-specific pricing and availability (`BranchMenuItem`).
- **Smart Branch Selection** — When ordering, customers can pick a branch manually or provide GPS coordinates to auto-detect the **nearest branch**.
- **Session-Based Cart** — A cart is created per order flow and stored in the session; items are validated to belong to the same branch.
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
| `Cart`            | A session-based cart tied to a single branch.                          |
| `CartItem`        | A line item in a cart referencing a `BranchMenuItem`.                  |
| `Order`           | A placed order with type (pickup/delivery) and status.                 |
| `OrderItem`       | A snapshot line item of an order (name, price, quantity).              |

### Key Routes

| Method | Path                    | Action                        |
|--------|-------------------------|-------------------------------|
| GET    | `/`                     | Start an order (type + branch)|
| GET    | `/order/start`          | Start an order (type + branch)|
| GET    | `/cart`                 | View current cart             |
| POST   | `/orders`               | Place order from cart         |
| GET    | `/branches/:id`         | View branch details           |
| GET    | `/branches/:id/menu`    | View a branch's menu          |
   
## Ordering Flow

1. **Start** — The customer chooses an order type (Pickup or Delivery) and either selects a branch or enters GPS coordinates.
2. **Branch Selection** — If GPS is provided without a branch, the app finds the nearest branch using a flat-earth distance approximation.
3. **Browse Menu** — A new cart is created for the selected branch and stored in the session; the customer browses the branch's menu and adds items.
4. **Review Cart** — The cart shows all items, quantities, and the running total.
5. **Place Order** — The order is created with a snapshot of each item's name and price, the total is calculated, and the cart is cleared.

## Testing

Run the test suite with:

```bash
bin/rails test
```
