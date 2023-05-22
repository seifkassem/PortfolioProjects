SELECT
	orders.order_id,
	CONCAT(customers.first_name,' ', customers.last_name) AS customers,
	customers.city,
	customers.state,
	orders.order_date,
	SUM(order_items.quantity) AS total_units,
	SUM(order_items.quantity * order_items.list_price) AS total_revenue,
	products.product_name,
	categories.category_name,
	stores.store_name,
	CONCAT(staffs.first_name, ' ', staffs.last_name) AS seller
FROM sales.orders orders
JOIN sales.customers customers
	ON orders.customer_id = customers.customer_id
JOIN sales.order_items order_items
	ON orders.order_id = order_items.order_id
JOIN production.products products
	ON order_items.product_id = products.product_id
JOIN production.categories categories
	ON products.category_id = categories.category_id
JOIN sales.stores stores
	ON orders.store_id = stores.store_id
JOIN sales.staffs staffs
	ON orders.staff_id = staffs.staff_id
GROUP BY
	orders.order_id,
	CONCAT(customers.first_name,' ', customers.last_name),
	customers.city,
	customers.state,
	order_date,
	products.product_name,
	categories.category_name,
	stores.store_name,
	CONCAT(staffs.first_name, ' ', staffs.last_name)