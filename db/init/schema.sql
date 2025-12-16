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
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), -- Unik ID for hver reservasjon
  customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,  -- Referanse til kunde
  table_id INT REFERENCES restaurant_tables(id) ON DELETE SET NULL, -- Referanse til bord
  booking_time TIMESTAMP WITH TIME ZONE NOT NULL, -- Tidspunkt for reservasjonen
  guests INT NOT NULL DEFAULT 1, -- Antall gjester
  status VARCHAR(20) NOT NULL DEFAULT 'booked', -- booked, cancelled, completed
  note TEXT, -- Eventuelle notater fra kunden
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() -- Tidspunkt for opprettelse
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

-- employees
CREATE TABLE IF NOT EXISTS employees (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL,
  role VARCHAR(20) DEFAULT 'staff'
);

-- demo-bruker
INSERT INTO employees (username, password)
VALUES ('Dana', '1234')
ON CONFLICT DO NOTHING;


-- Indexer for ytelse
CREATE INDEX IF NOT EXISTS idx_bookings_time ON bookings(booking_time);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
