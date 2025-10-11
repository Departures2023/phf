# PHF App Visual Diagram Specification

## 🎨 **Diagram Layout & Structure**

### **Overall Layout:**
- **Format**: Landscape orientation
- **Background**: White with light gray grid
- **Title**: "PHF Student Marketplace - System Architecture" (Top center, large font)

### **Main Components (Left to Right):**

#### **1. MOBILE APP LAYER (Left Side)**
```
┌─────────────────────────────────┐
│        FLUTTER MOBILE APP       │
│                                 │
│  ┌─────────────────────────────┐ │
│  │     Bottom Navigation       │ │
│  │  [🏠] [🛒] [📷] [👤]      │ │
│  │  Home Cart Sell Profile     │ │
│  └─────────────────────────────┘ │
│                                 │
│  ┌─────────────────────────────┐ │
│  │        Homepage             │ │
│  │  ┌─────────────────────────┐ │ │
│  │  │   Category Navigation   │ │ │
│  │  │ [📚][👕][🏠][💻]       │ │ │
│  │  │ [🍕][🪑][🏠][🚲]       │ │ │
│  │  └─────────────────────────┘ │ │
│  │                             │ │
│  │  ┌─────────────────────────┐ │ │
│  │  │     Item Grid (2x2)     │ │ │
│  │  │ [📖$25] [💻$300]       │ │ │
│  │  │ [🪑$50] [🚲$150]       │ │ │
│  │  └─────────────────────────┘ │ │
│  └─────────────────────────────┘ │
└─────────────────────────────────┘
```

#### **2. CONNECTION ARROWS (Center)**
- **Arrow 1**: "Real-time Data Sync" (pointing right)
- **Arrow 2**: "User Actions" (pointing left)

#### **3. FIREBASE BACKEND (Right Side)**
```
┌─────────────────────────────────┐
│        FIREBASE BACKEND         │
│                                 │
│  ┌─────────┐ ┌─────────┐ ┌─────┐ │
│  │FIRESTORE│ │ STORAGE │ │AUTH │ │
│  │Database │ │ Images  │ │Users│ │
│  │         │ │         │ │     │ │
│  │• Users  │ │• Photos │ │• 🔐 │ │
│  │• Items  │ │• Icons  │ │• ⭐ │ │
│  │• Chats  │ │• Avatars│ │• 👤 │ │
│  └─────────┘ └─────────┘ └─────┘ │
└─────────────────────────────────┘
```

## 🎨 **Visual Design Specifications:**

### **Colors:**
- **Primary**: Pink/Magenta (#C8178A)
- **Secondary**: Green (#4CAF50)
- **Background**: Light Beige (#EDD3BE)
- **Text**: Dark Gray (#333333)
- **Boxes**: White with light gray borders

### **Typography:**
- **Title**: Bold, 24pt, Dark Gray
- **Headers**: Bold, 16pt, Primary Pink
- **Body Text**: Regular, 12pt, Dark Gray
- **Icons**: 20pt emoji or custom icons

### **Box Styling:**
- **Border**: 2px solid light gray
- **Border Radius**: 8px
- **Padding**: 12px
- **Shadow**: Light drop shadow
- **Background**: White

### **Connections:**
- **Arrows**: 3px thick, Primary Pink
- **Labels**: Small text above arrows
- **Flow**: Left to right, top to bottom

## 📱 **User Flow Diagram (Separate Slide):**

### **Layout:**
```
┌─────────────────────────────────────────────────────────────┐
│                    USER TRANSACTION FLOW                    │
└─────────────────────────────────────────────────────────────┘

👤 SELLER                    👤 BUYER
│                           │
├─ 📷 Post Item            ├─ 🏠 Browse
├─ 📱 Upload Photo         ├─ 👀 View Item
├─ 💬 Chat                 ├─ 💬 Chat
├─ 🤝 Meet Campus          ├─ 🤝 Meet Campus
├─ 💰 Exchange             ├─ 💰 Pay
└─ ⭐ Rate Buyer           └─ ⭐ Rate Seller

🔄 Real-time Updates: Both see completion instantly
```

## 🛠️ **Tools to Create This Diagram:**

### **Recommended (Easiest):**
1. **Draw.io** (draw.io) - Free, web-based
2. **Lucidchart** - Free tier, professional
3. **Figma** - Free for students, collaborative

### **Steps to Create:**
1. Create new diagram
2. Add rectangles for each component
3. Add text labels
4. Add emoji icons or custom icons
5. Connect with arrows
6. Apply colors and styling
7. Export as PNG/JPG

### **Quick Start in Draw.io:**
1. Go to draw.io
2. Choose "Blank Diagram"
3. Drag rectangles from left panel
4. Add text by double-clicking
5. Use "Arrows" from left panel
6. Style with right panel options

## 📋 **Content for Each Box:**

### **Mobile App Box:**
- Title: "Flutter Mobile App"
- Subtitle: "iOS & Android"
- Features: "Navigation, Categories, Item Grid, Real-time UI"

### **Firebase Box:**
- Title: "Firebase Backend"
- Subtitle: "Google Cloud Platform"
- Features: "Database, Storage, Authentication, Real-time Sync"

### **User Flow Boxes:**
- Seller: "Post → Chat → Meet → Exchange → Rate"
- Buyer: "Browse → View → Chat → Meet → Pay → Rate"

This specification gives you everything needed to create a professional visual diagram in any tool!
