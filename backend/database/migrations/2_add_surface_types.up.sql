CREATE TABLE IF NOT EXISTS surface_types
(
    id         UUID PRIMARY KEY                     DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

    name TEXT NOT NULL,
    min_value DOUBLE PRECISION NOT NULL,
    max_value DOUBLE PRECISION NOT NULL
);