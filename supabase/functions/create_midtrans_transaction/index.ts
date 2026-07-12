import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req: Request) => {
  try {
    // Enable CORS
    if (req.method === 'OPTIONS') {
      return new Response('ok', { headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      }})
    }

    const { order_id } = await req.json()
    if (!order_id) throw new Error('Order ID is required')

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Ambil data order dari database (supaya harga tidak bisa dipalsukan klien)
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .select('*, profiles!user_id(full_name, email, phone_number)')
      .eq('id', order_id)
      .single()

    if (orderError || !order) throw new Error('Order not found')
    
    // Validasi harga (pastikan Admin sudah menset final_price)
    if (!order.final_price || order.final_price <= 0) {
      throw new Error('Pesanan ini belum memiliki harga akhir (Final Price) dari Admin.')
    }

    // Midtrans Server Key dari Environment Variables (Base64 Encoded)
    const serverKey = Deno.env.get('MIDTRANS_SERVER_KEY')!
    const authString = btoa(`${serverKey}:`)

    // URL Endpoint (Default Sandbox)
    // Ubah jadi https://app.midtrans.com/snap/v1/transactions untuk Production
    const midtransUrl = 'https://app.sandbox.midtrans.com/snap/v1/transactions'

    // Parameter Transaksi Midtrans
    const parameter = {
      transaction_details: {
        order_id: `HELIOT-${order.id.substring(0, 8)}-${Date.now()}`, // Midtrans butuh Order ID unik per percobaan
        gross_amount: Math.round(order.final_price)
      },
      item_details: [
        {
          id: order.id,
          price: Math.round(order.final_price),
          quantity: 1,
          name: order.project_title.substring(0, 50) // Max 50 char
        }
      ],
      customer_details: {
        first_name: order.profiles?.full_name || order.customer_name || 'Customer',
        email: order.profiles?.email || 'customer@heliot.com',
        phone: order.profiles?.phone_number || order.customer_phone || ''
      },
      custom_field1: order.id // Simpan UUID penuh di sini agar bisa diambil oleh webhook
    }

    // Request ke Midtrans API
    const midtransRes = await fetch(midtransUrl, {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': `Basic ${authString}`
      },
      body: JSON.stringify(parameter)
    })

    const midtransData = await midtransRes.json()

    if (!midtransRes.ok) {
      throw new Error(`Midtrans Error: ${JSON.stringify(midtransData)}`)
    }

    // Kembalikan Snap URL ke Flutter App
    return new Response(JSON.stringify({ 
      success: true, 
      redirect_url: midtransData.redirect_url,
      token: midtransData.token
    }), {
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: String(error) }), {
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      status: 400,
    })
  }
})
