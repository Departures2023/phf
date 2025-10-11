# PHF Student Marketplace - 2-Minute Presentation

## 🎯 **THE PROBLEM** (30 seconds)

**Grinnell students lack a unified marketplace for buying and selling items.**

Currently, students rely on:
- ❌ **Fragmented WeChat groups** - hard to find items
- ❌ **Informal Facebook posts** - no transaction security  
- ❌ **Word-of-mouth trading** - limited reach
- ❌ **No rating system** - trust issues between buyers/sellers

**Result**: Students struggle to find textbooks, furniture, electronics, and even dining dollars - wasting time and money.

---

## 📊 **THE SOLUTION** (60 seconds)

**PHF - A dedicated marketplace app for Grinnell students**

### Key Features:
- 🏠 **Smart Homepage**: Browse items by category (Electronics, Clothing, Furniture, etc.)
- 👤 **Trust System**: Separate buyer/seller ratings for accountability
- 📱 **Mobile-First**: Native Flutter app for iOS/Android
- 🔥 **Real-time Updates**: Firebase-powered live listings
- 💬 **In-app Chat**: Secure communication between buyers/sellers
- 📊 **Transaction History**: Complete record of all trades

### Technical Architecture:
```
┌─────────────────────────────────────────────────────────────┐
│                    PHF STUDENT MARKETPLACE                  │
│                     (Flutter Mobile App)                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    FIREBASE BACKEND                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Firestore  │  │   Storage   │  │    Auth     │        │
│  │  Database   │  │  (Images)   │  │  (Users)    │        │
│  │             │  │             │  │             │        │
│  │ • Users     │  │ • Item Pics │  │ • Login     │        │
│  │ • Items     │  │ • Avatars   │  │ • Ratings   │        │
│  │ • Chats     │  │ • Icons     │  │ • Security  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

### User Experience:
1. **Browse**: Students see categorized items on homepage
2. **Connect**: Tap item → chat with seller → negotiate price
3. **Trade**: Meet on campus → exchange items → rate each other
4. **Build Reputation**: High ratings = trusted buyer/seller

---

## 💰 **FUNDING REQUEST** (30 seconds)

**We need $5,000 to complete PHF and launch for Grinnell students.**

### Budget Breakdown:
- 💻 **Development**: $2,500 (3 months of development time)
- 🔥 **Firebase Services**: $500 (database, storage, hosting)
- 🎨 **UI/UX Design**: $1,000 (professional design assets)
- 📱 **App Store Fees**: $200 (iOS/Android publishing)
- 🚀 **Marketing**: $800 (campus promotion, flyers, social media)

### Impact:
- **500+ Grinnell students** will have access to a secure marketplace
- **Reduce waste** by facilitating item reuse
- **Save students money** through peer-to-peer trading
- **Build community** through trusted transactions

### Timeline:
- **Month 1**: Complete authentication and chat features
- **Month 2**: Add payment integration and testing
- **Month 3**: Launch and campus promotion

**Help us create the marketplace Grinnell students need. Every dollar brings us closer to solving this campus-wide problem.**

---

## 🎯 **Call to Action**
*"Invest in PHF today and help us build the marketplace that will transform how Grinnell students buy and sell items. Thank you."*

---

**Total Presentation Time: 2 minutes**
**Key Message: PHF solves a real problem for Grinnell students with a proven technical solution**
