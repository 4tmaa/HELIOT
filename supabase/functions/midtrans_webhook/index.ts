import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { crypto } from "https://deno.land/std@0.168.0/crypto/mod.ts";

async function generateSHA512(text: string) {
  const encoder = new TextEncoder();
  const data = encoder.encode(text);
  const hashBuffer = await crypto.subtle.digest("SHA-512", data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  return hashHex;
}

serve(async (req: Request) => {
  try {
    const payload = await req.json()
    console.log("Midtrans Payload:", payload)

    const {
      order_id,
      status_code,
      gross_amount,
      signature_key,
      transaction_status,
      custom_field1
    } = payload

    const serverKey = Deno.env.get('MIDTRANS_SERVER_KEY')!
    
    // Verifikasi Keamanan Signature Key dari Midtrans
    const rawString = `${order_id}${status_code}${gross_amount}${serverKey}`
    const calculatedSignature = await generateSHA512(rawString)

    if (calculatedSignature !== signature_key) {
      throw new Error('Invalid Signature Key! Potensi pemalsuan webhook.')
    }

    // Ambil ID pesanan asli dari custom_field1 (disimpan saat create transaction)
    const originalOrderId = custom_field1;
    if (!originalOrderId) {
       throw new Error('Missing original Order ID in custom_field1')
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Cari pesanan asli
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .select('id, status')
      .eq('id', originalOrderId)
      .single()

    if (orderError || !order) {
      throw new Error('Order not found in database')
    }

    let newStatus = order.status

    if (transaction_status == 'capture' || transaction_status == 'settlement') {
      newStatus = 'DIPROSES' // Lunas dan siap dikerjakan
    } else if (transaction_status == 'deny' || transaction_status == 'cancel' || transaction_status == 'expire') {
      newStatus = 'DIBATALKAN' // Gagal atau dibatalkan
    } else if (transaction_status == 'pending') {
      newStatus = 'Menunggu Pembayaran' // Update status agar terlihat berubah
    }

    // Update status pesanan
    if (newStatus !== order.status) {
      await supabase
        .from('orders')
        .update({ status: newStatus })
        .eq('id', order.id)
    }

    return new Response(JSON.stringify({ status: 'success' }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    console.error("Webhook Error:", error)
    return new Response(JSON.stringify({ error: String(error) }), {
      headers: { 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
