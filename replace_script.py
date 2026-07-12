import re

file_path = 'lib/screens/order/detail_pesanan_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("orderData['", "_currentOrderData['")
content = content.replace("orderData?", "_currentOrderData?")
content = content.replace("orderData!", "_currentOrderData!")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Replaced successfully")
