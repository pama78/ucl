class OrderItem
  # Doplnte.
  attr_reader :product_code, :product_name, :price, :quantity
  def initialize(product_code, product_name, price, quantity)
    @product_code = product_code
    @product_name = product_name
    @price = price
    @quantity = quantity
  end
end

class Order
  # Doplnte.
  attr_reader :order_number, :date, :shipping_address, :billing_address, :items
  def initialize (order_number, date, shipping_address, billing_address)
    # Doplnte.
    @items = []
    #p "init order"
    @order_number = order_number
    @date = date
    @shipping_address = shipping_address
    @billing_address = billing_address
  end

  def add_item(item)
#    p "adding items #{item}"
    @items << item
  end
end
