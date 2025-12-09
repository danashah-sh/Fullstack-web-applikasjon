-- schema.sql: Oppretter databasen for restaurant-app

-- Extensions (om nødvendig)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- customers
CREATE TABLE IF NOT EXISTS customers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(200),
  phone VARCHAR(30),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- restaurant_tables
CREATE TABLE IF NOT EXISTS restaurant_tables (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50),
  seats INT NOT NULL,
  location VARCHAR(100)
);

-- bookings (reservasjoner)
CREATE TABLE IF NOT EXISTS bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
  table_id INT REFERENCES restaurant_tables(id) ON DELETE SET NULL,
  booking_time TIMESTAMP WITH TIME ZONE NOT NULL,
  guests INT NOT NULL DEFAULT 1,
  status VARCHAR(20) NOT NULL DEFAULT 'booked', -- booked, cancelled, completed
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- menu_items
CREATE TABLE IF NOT EXISTS menu_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(200) NOT NULL,
  description TEXT,
  price NUMERIC(8,2) NOT NULL,
  category VARCHAR(100),
  available BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- orders
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
  customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
  table_id INT REFERENCES restaurant_tables(id) ON DELETE SET NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'open', -- open, served, paid, cancelled
  total NUMERIC(10,2) DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- order_items
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  menu_item_id UUID REFERENCES menu_items(id) ON DELETE SET NULL,
  quantity INT NOT NULL DEFAULT 1,
  unit_price NUMERIC(8,2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Indexer for ytelse
CREATE INDEX IF NOT EXISTS idx_bookings_time ON bookings(booking_time);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
