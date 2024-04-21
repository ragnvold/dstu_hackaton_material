CREATE TABLE warehouse_types (
	warehouse_type_id INTEGER PRIMARY KEY NOT NULL,
	type TEXT NOT NULL
);
CREATE TABLE warehouses (
	warehouse_id INTEGER PRIMARY KEY NOT NULL,
	name TEXT NOT NULL,
	warehouse_type_id INTEGER NOT NULL REFERENCES warehouse_types(warehouse_type_id),
	latitude REAL NOT NULL,
	longitude REAL NOT NULL
);
CREATE TABLE transports (
	transport_id INTEGER PRIMARY KEY NOT NULL,
	volume REAL NOT NULL
);
CREATE TABLE transportations (
	transportation_id INTEGER PRIMARY KEY NOT NULL,
	from_id INTEGER REFERENCES warehouses(warehouse_id),
	to_id INTEGER REFERENCES warehouses(warehouse_id),
	transport_id INTEGER REFERENCES transports(transport_id),
	started_at INTEGER NOT NULL,
	ended_at INTEGER
);
CREATE TABLE movements (
	batch_id INTEGER NOT NULL REFERENCES batches(batch_id),
	transportation_id INTEGER NOT NULL REFERENCES transportations(transportation_id),
	PRIMARY KEY(batch_id, transportation_id)
);
CREATE TABLE batches (
	batch_id INTEGER PRIMARY KEY NOT NULL,
	product_id INTEGER NOT NULL REFERENCES products(product_id),
	amount INTEGER NOT NULL
);
CREATE TABLE products (
	product_id INTEGER PRIMARY KEY NOT NULL,
	name TEXT NOT NULL,
	expiration_time INTEGER NOT NULL
);
CREATE TABLE sales (
	sale_id INTEGER PRIMARY KEY NOT NULL,
	price REAL NOT NULL,
	amount INTEGER NOT NULL,
	batch_id INTEGER NOT NULL REFERENCES batches(batch_id)
);
CREATE TABLE discounts (
	discount_id INTEGER PRIMARY KEY NOT NULL,
	warehouse_id INTEGER NOT NULL REFERENCES warehouses(warehouse_id),
	batch_id INTEGER NOT NULL REFERENCES batches(batch_id),
	amount REAL NOT NULL,
	started_at INTEGER NOT NULL,
	ended_at INTEGER
);
CREATE VIEW product_positions(batch_id, warehouse_id) AS
SELECT DISTINCT(batch_id)
batch_id,
FIRST_VALUE(to_id) OVER(PARTITION BY batch_id ORDER BY transportation_id DESC)
FROM batches
JOIN movements USING(batch_id)
JOIN transportations USING(transportation_id);

CREATE VIEW real_sales AS
SELECT SUM((price - COALESCE(discounts.amount, 0)) * sales.amount) FROM
sales
JOIN batches USING(batch_id)
JOIN product_positions USING(batch_id)
JOIN discounts
	ON discounts.batch_id = batches.batch_id
	AND discounts.warehouse_id = product_positions.warehouse_id
GROUP BY sale_id;

CREATE VIEW transport_positions(transport_id, warehouse_id) AS
SELECT DISTINCT (transport_id)
transport_id,
FIRST_VALUE(to_id) OVER
	(PARTITION BY transport_id ORDER BY ended_at DESC)
FROM transportations;

-- CREATE VIEW 
INSERT INTO warehouse_types(type) VALUES('shop'), ('warehouse'), ('factory');
