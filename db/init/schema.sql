-- schema.sql
-- Lager databasen for restaurant-appen

-- Slår på støtte for UUID (unik ID)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

--------------------------------------------------
-- KUNDER
--------------------------------------------------
CREATE TABLE IF NOT EXISTS customers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), 
  -- Unik ID for hver kunde

  first_name VARCHAR(100) NOT NULL, 
  -- Kundens fornavn

  last_name VARCHAR(100) NOT NULL, 
  -- Kundens etternavn

  email VARCHAR(200), 
  -- Kundens e-post

  phone VARCHAR(30), 
  -- Kundens telefonnummer

  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
  -- Når kunden ble lagt til
);

--------------------------------------------------
-- RESTAURANTBORD
--------------------------------------------------
CREATE TABLE IF NOT EXISTS restaurant_tables (
  id SERIAL PRIMARY KEY,
  -- Unik ID for hvert bord

  name VARCHAR(50),
  -- Navn på bordet (f.eks. Bord 1)

  seats INT NOT NULL,
  -- Hvor mange plasser bordet har

  location VARCHAR(100)
  -- Hvor bordet står
);

--------------------------------------------------
-- RESERVASJONER
--------------------------------------------------
CREATE TABLE IF NOT EXISTS bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  -- Unik ID for reservasjon

  customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
  -- Kobler reservasjon til kunde

  table_id INT REFERENCES restaurant_tables(id) ON DELETE SET NULL,
  -- Kobler reservasjon til bord

  booking_time TIMESTAMP WITH TIME ZONE NOT NULL,
  -- Tidspunkt for reservasjonen

  guests INT NOT NULL DEFAULT 1,
  -- Antall gjester

  status VARCHAR(20) NOT NULL DEFAULT 'booked',
  -- Status: booked, cancelled, completed

  note TEXT,
  -- Kommentar fra kunden

  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
  -- Når reservasjonen ble laget
);

--------------------------------------------------
-- BESTILLINGER (ORDERS)
--------------------------------------------------
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  -- Unik ID for bestilling

  booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
  -- Kobles til reservasjon

  customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
  -- Kobles til kunde

  table_id INT REFERENCES restaurant_tables(id) ON DELETE SET NULL,
  -- Kobles til bord

  status VARCHAR(20) NOT NULL DEFAULT 'open',
  -- Status: open, served, paid, cancelled

  total NUMERIC(10,2) DEFAULT 0,
  -- Totalpris

  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
  -- Når bestillingen ble laget
);

--------------------------------------------------
-- BESTILLINGSINNHOLD (HVA SOM ER BESTILT)
--------------------------------------------------
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  -- Unik ID

  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  -- Kobles til bestilling

  menu_item_id UUID REFERENCES menu_items(id) ON DELETE SET NULL,
  -- Kobles til menyrett

  quantity INT NOT NULL DEFAULT 1,
  -- Antall av retten

  unit_price NUMERIC(8,2) NOT NULL,
  -- Pris per stk

  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
  -- Når varen ble lagt til
);

--------------------------------------------------
-- ANSATTE
--------------------------------------------------
CREATE TABLE IF NOT EXISTS employees (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  -- Unik ID for ansatt

  username VARCHAR(50) UNIQUE NOT NULL,
  -- Brukernavn

  password VARCHAR(100) NOT NULL,
  -- Passord

  role VARCHAR(20) DEFAULT 'staff'
  -- Rolle (f.eks. staff eller admin)
);

--------------------------------------------------
-- DEMO-BRUKER
--------------------------------------------------
INSERT INTO employees (username, password)
VALUES ('Dana', '1234')
ON CONFLICT DO NOTHING;
-- Legger til testbruker hvis den ikke finnes

--------------------------------------------------
-- INDEKSER (GJØR SØK RASKERE)
--------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_bookings_time ON bookings(booking_time);
-- Raskere søk på reservasjonstid

CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
-- Raskere søk på ordrestatus
