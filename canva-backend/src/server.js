// src/server.js
import express from 'express'
import dotenv from 'dotenv'
import cors from 'cors'
import axios from 'axios'

dotenv.config()

const app = express()
app.use(cors({ origin: process.env.FRONTEND_URL || '*' }))
app.use(express.json())

const CANVA_API = 'https://api.canva.com/rest/v1'
const CLIENT_ID = process.env.CANVA_CLIENT_ID
const CLIENT_SECRET = process.env.CANVA_CLIENT_SECRET
const REDIRECT_URI = process.env.CANVA_REDIRECT_URI
const SCOPES = process.env.CANVA_SCOPES

// In-memory token store (for dev only)
let accessToken = null
let refreshToken = null

// --- OAuth Flow ---

// Step 1: Redirect to Canva OAuth
app.get('/auth', (req, res) => {
  const authUrl = `https://www.canva.com/api/oauth/authorize?client_id=${CLIENT_ID}&redirect_uri=${encodeURIComponent(REDIRECT_URI)}&response_type=code&scope=${encodeURIComponent(SCOPES)}`
  res.redirect(authUrl)
})

// Step 2: Handle callback
app.get('/callback', async (req, res) => {
  const { code, error } = req.query
  if (error) {
    return res.status(400).send(`OAuth error: ${error}`)
  }
  if (!code) {
    return res.status(400).send('No authorization code received')
  }

  try {
    const tokenRes = await axios.post('https://api.canva.com/rest/v1/oauth/token', {
      grant_type: 'authorization_code',
      code,
      redirect_uri: REDIRECT_URI,
    }, {
      auth: { username: CLIENT_ID, password: CLIENT_SECRET },
      headers: { 'Content-Type': 'application/json' },
    })

    accessToken = tokenRes.data.access_token
    refreshToken = tokenRes.data.refresh_token

    res.send(`
      <html><body style="font-family:sans-serif;text-align:center;padding:40px">
        <h2>✅ Canva Connected!</h2>
        <p>Access token saved. You can close this window.</p>
        <p>Token expires in: ${tokenRes.data.expires_in}s</p>
      </body></html>
    `)
  } catch (err) {
    console.error('Token exchange error:', err.response?.data || err.message)
    res.status(500).send('Failed to exchange token: ' + (err.response?.data?.error_description || err.message))
  }
})

// --- API Proxy ---

// Check auth status
app.get('/status', (req, res) => {
  res.json({ authenticated: !!accessToken })
})

// Create a design from template/prompt
app.post('/create-design', async (req, res) => {
  if (!accessToken) return res.status(401).json({ error: 'Not authenticated. Visit /auth first.' })

  const { title, width, height } = req.body
  try {
    const designRes = await axios.post(`${CANVA_API}/designs`, {
      design_type: {
        type: 'custom',
        width: width || 512,
        height: height || 512,
      },
      title: title || 'Shonen Grand Asset',
    }, {
      headers: { Authorization: `Bearer ${accessToken}` },
    })

    res.json(designRes.data)
  } catch (err) {
    console.error('Create design error:', err.response?.data || err.message)
    res.status(err.response?.status || 500).json(err.response?.data || { error: err.message })
  }
})

// Upload asset from URL
app.post('/upload-asset', async (req, res) => {
  if (!accessToken) return res.status(401).json({ error: 'Not authenticated' })

  const { name, url } = req.body
  try {
    const assetRes = await axios.post(`${CANVA_API}/assets`, {
      name: name || 'asset',
      url,
    }, {
      headers: { Authorization: `Bearer ${accessToken}` },
    })

    res.json(assetRes.data)
  } catch (err) {
    console.error('Upload asset error:', err.response?.data || err.message)
    res.status(err.response?.status || 500).json(err.response?.data || { error: err.message })
  }
})

// Export design
app.post('/export-design', async (req, res) => {
  if (!accessToken) return res.status(401).json({ error: 'Not authenticated' })

  const { designId, format } = req.body
  try {
    const exportRes = await axios.post(`${CANVA_API}/exports`, {
      design_id: designId,
      format: { type: format || 'png' },
    }, {
      headers: { Authorization: `Bearer ${accessToken}` },
    })

    // Poll for completion
    const jobId = exportRes.data.job.id
    let status = 'in_progress'
    let downloadUrl = null

    while (status === 'in_progress') {
      await new Promise((r) => setTimeout(r, 2000))
      const jobRes = await axios.get(`${CANVA_API}/exports/${jobId}`, {
        headers: { Authorization: `Bearer ${accessToken}` },
      })
      status = jobRes.data.job.status
      if (status === 'success') {
        downloadUrl = jobRes.data.job.urls?.[0]
      }
    }

    res.json({ status, downloadUrl, jobId })
  } catch (err) {
    console.error('Export error:', err.response?.data || err.message)
    res.status(err.response?.status || 500).json(err.response?.data || { error: err.message })
  }
})

// List designs
app.get('/designs', async (req, res) => {
  if (!accessToken) return res.status(401).json({ error: 'Not authenticated' })

  try {
    const designsRes = await axios.get(`${CANVA_API}/designs`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    })
    res.json(designsRes.data)
  } catch (err) {
    console.error('List designs error:', err.response?.data || err.message)
    res.status(err.response?.status || 500).json(err.response?.data || { error: err.message })
  }
})

app.listen(process.env.PORT || 3000, () => {
  console.log(`🎨 Canva backend running on http://localhost:${process.env.PORT || 3000}`)
  console.log(`   → Visit http://localhost:${process.env.PORT || 3000}/auth to connect Canva`)
})
