-- ShopNest schema: run this first, then import the CSVs

CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    full_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(150) UNIQUE NOT NULL,
    city            VARCHAR(50),
    signup_date     DATE NOT NULL,
    membership_tier VARCHAR(20) NOT NULL DEFAULT 'free'
                    CHECK (membership_tier IN ('free', 'prime'))
);

CREATE TABLE membership_plans (
    plan_id         SERIAL PRIMARY KEY,
    tier_name       VARCHAR(20) NOT NULL,
    monthly_price   NUMERIC(8,2) NOT NULL,
    billing_cycle   VARCHAR(10) NOT NULL DEFAULT 'monthly'
);

CREATE TABLE customer_subscriptions (
    subscription_id SERIAL PRIMARY KEY,
    customer_id     INT NOT NULL REFERENCES customers(customer_id),
    plan_id         INT NOT NULL REFERENCES membership_plans(plan_id),
    start_date      DATE NOT NULL,
    end_date        DATE,
    status          VARCHAR(20) NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active', 'cancelled', 'expired'))
);

CREATE TABLE categories (
    category_id     SERIAL PRIMARY KEY,
    category_name   VARCHAR(60) NOT NULL
);

CREATE TABLE products (
    product_id      SERIAL PRIMARY KEY,
    product_name    VARCHAR(150) NOT NULL,
    category_id     INT REFERENCES categories(category_id),
    price           NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    cost            NUMERIC(10,2) NOT NULL CHECK (cost >= 0),
    launch_date     DATE
);

CREATE TABLE orders (
    order_id        SERIAL PRIMARY KEY,
    customer_id     INT NOT NULL REFERENCES customers(customer_id),
    order_date      DATE NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'completed'
                    CHECK (status IN ('completed', 'cancelled', 'returned'))
);

CREATE TABLE order_items (
    order_item_id   SERIAL PRIMARY KEY,
    order_id        INT NOT NULL REFERENCES orders(order_id),
    product_id      INT NOT NULL REFERENCES products(product_id),
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10,2) NOT NULL
);

CREATE TABLE payments (
    payment_id      SERIAL PRIMARY KEY,
    order_id        INT NOT NULL REFERENCES orders(order_id),
    payment_method  VARCHAR(30) NOT NULL,
    amount          NUMERIC(10,2) NOT NULL,
    paid_at         TIMESTAMP NOT NULL
);

CREATE TABLE reviews (
    review_id       SERIAL PRIMARY KEY,
    product_id      INT NOT NULL REFERENCES products(product_id),
    customer_id     INT NOT NULL REFERENCES customers(customer_id),
    rating          INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_date     DATE NOT NULL
);