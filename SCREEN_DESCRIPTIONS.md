# 🎨 LuxeFinds Mobile Client - Screen Descriptions

**Document Version:** 1.0  
**Last Updated:** February 12, 2026  
**Application:** Flutter Mobile Client for LuxeFinds

---

## 📱 Complete Screen Overview

The LuxeFinds mobile client consists of **7 main screens** plus supporting components, organized into logical flows for authentication, shopping, and account management.

### Screen Navigation Map

```
LoginScreen ─────────┐
                    ├──→ HomeScreen ──→ ProductListScreen ──→ ProductDetailScreen
SignupScreen ───────┘                                                    ↓
                                                                    CartScreen
                                                                        ↓
                                                                  CheckoutScreen
                                                                        ↓
                                                                   OrdersScreen ──→ OrderDetailScreen
                                                                        ↑
ProfileScreen (accessible from any screen via header icon)──────────────┘
```

---

## 🔐 Authentication Screens

### 1. **LoginScreen** (`lib/screens/auth/login_screen.dart`)

#### Purpose
User authentication entry point. Allows existing users to sign in to their account.

#### Key Features
- **Email Input Field**
  - Validates email format with basic regex
  - Prefixed with email icon
  - Placeholder: "Enter your email"
  
- **Password Input Field**
  - Toggle visibility button (eye icon)
  - Minimum 6 characters validation
  - Obscured by default
  
- **Sign In Button**
  - Shows loading spinner during authentication
  - Disabled while request is in progress
  - Success redirects to `/home`
  
- **Error Handling**
  - Displays error messages via SnackBar
  - Red background for error indication

- **Navigation Links**
  - "Don't have an account? Sign Up" → Navigates to `/signup`

#### UI Layout
```
┌──────────────────────────────────┐
│  AppBar: "Login"                 │
├──────────────────────────────────┤
│                                  │
│  "Welcome Back" (heading)        │
│  "Sign in to your account"       │
│                                  │
│  [Email input field]             │
│  [Password input field + eye]    │
│                                  │
│  [Sign In button]                │
│                                  │
│  Don't have account? Sign Up ←───┤
│                                  │
└──────────────────────────────────┘
```

#### State Management
- Uses `authStateProvider` from Riverpod
- Tracks `isLoading` state during authentication
- Stores tokens in secure storage on success

#### Validation Rules
- Email: Non-empty + basic regex format check
- Password: Non-empty + minimum 6 characters

---

### 2. **SignupScreen** (`lib/screens/auth/signup_screen.dart`)

#### Purpose
New user account creation. Allows customers to register for LuxeFinds.

#### Key Features
- **Full Name Input**
  - Validates minimum 2 characters
  - Prefixed with person icon
  
- **Email Input**
  - Same validation as LoginScreen
  - Must be unique (backend validation)
  
- **Password Input**
  - Same as LoginScreen with visibility toggle
  - Minimum 6 characters
  
- **Confirm Password Field**
  - Separate visibility toggle
  - Must match password field exactly
  
- **Create Account Button**
  - Shows loading spinner
  - Success redirects to `/home`
  
- **Error Display**
  - SnackBar notifications for errors
  
- **Navigation**
  - "Already have an account? Sign In" → Pops to previous screen

#### UI Layout
```
┌──────────────────────────────────┐
│  AppBar: "Create Account"        │
├──────────────────────────────────┤
│                                  │
│  "Join LuxeFinds" (heading)      │
│  "Create your account..."        │
│                                  │
│  [Full Name input]               │
│  [Email input]                   │
│  [Password input + eye]          │
│  [Confirm Password input + eye]  │
│                                  │
│  [Create Account button]         │
│                                  │
│  Already have account? Sign In   │
│                                  │
└──────────────────────────────────┘
```

#### Validation Rules
- Name: Non-empty + minimum 2 characters
- Email: Non-empty + regex format check
- Password: Non-empty + minimum 6 characters
- Confirm: Must match password exactly

#### Post-Registration Flow
- User automatically logged in
- Redirects to HomeScreen
- Auth token stored in secure storage

---

## 🏠 Home & Product Discovery

### 3. **HomeScreen** (`lib/screens/home/home_screen.dart`)

#### Purpose
Main landing screen after authentication. Showcases featured products and navigation.

#### Key Sections

**AppBar**
- Title: "LuxeFinds"
- Action buttons:
  - Shopping bag icon → Navigate to `/cart`
  - Person icon → Navigate to `/profile`

**Hero Section**
- Gradient background (dark to surface color)
- Personalized greeting: "Welcome, {UserName}"
- Description: "Discover premium luxury accessories"
- "Shop Now" button → Navigate to `/products`

**Categories Section**
- Displays all product categories in horizontal scrollable list
- Each category is a clickable chip/card
- Shows loading spinner while fetching
- Error display if categories fail to load
- Tapping category navigates to `/products?categoryId={id}`

**Featured Products Section**
- 2-column grid layout
- Shows first 6 featured products
- Each product card displays:
  - Product image (NetworkImage with error handling)
  - "Featured" badge (if flagged)
  - Product name (max 1 line, ellipsis)
  - Price in golden color
  - Stock status

**ProductCard Component**
```
┌──────────────────┐
│                  │ ← Product Image
│  [Featured]      │   (background image)
│                  │
├──────────────────┤
│ Product Name     │
│ $99.99          │
│ 5 in stock       │
└──────────────────┘
```

#### Loading & Error States
- Category loading: Centered CircularProgressIndicator
- Category error: Text display with error message
- Product loading: SizedBox with spinner
- Product error: Error text message

#### Navigation
- Tapping product card → `/products/{product.id}`
- Category chip → `/products?categoryId={category.id}`

---

### 4. **ProductListScreen** (`lib/screens/products/product_list_screen.dart`)

#### Purpose
Browse all products with filtering and search capabilities.

#### Key Features

**Search Bar**
- Real-time search across product names
- Clear button appears when text is entered
- Updates product list as user types
- Resets to page 1 on new search

**Category Filter Chips**
- "All" chip (removes category filter)
- Individual category chips
- Selected chip is highlighted
- Updates list when category changes
- Resets to page 1 on filter change

**Products Grid**
- 2-column layout (landscape-aware)
- Card-based product display
- Aspect ratio 0.7 (taller than wide)
- 12pt spacing between items

**Product Card Details**
- Product image with featured badge
- Product name (truncated with ellipsis)
- Price in golden color
- Stock availability indicator

**Empty State**
- Large shopping bag icon
- "No products found" message
- Centered on screen
- Indicates no results for current filters

**Error State**
- Error message display
- Allows user to retry

#### Filter Parameters
- `categoryId`: Filter by product category
- `search`: Full-text search
- `page`: Pagination support
- `limit`: Items per page (20)

#### UI Layout
```
┌────────────────────────────────┐
│  AppBar: "Products"            │
├────────────────────────────────┤
│  [Search bar with clear btn]   │
│  [Category filter chips → →]   │
│                                │
│  ┌──────────┐  ┌──────────┐   │
│  │ Product1 │  │ Product2 │   │
│  │  Image   │  │  Image   │   │
│  │ $99.99   │  │ $149.99  │   │
│  └──────────┘  └──────────┘   │
│  ┌──────────┐  ┌──────────┐   │
│  │ Product3 │  │ Product4 │   │
│  │  Image   │  │  Image   │   │
│  │ $79.99   │  │ $199.99  │   │
│  └──────────┘  └──────────┘   │
│                                │
└────────────────────────────────┘
```

---

### 5. **ProductDetailScreen** (`lib/screens/products/product_detail_screen.dart`)

#### Purpose
Detailed product view with images, description, and add-to-cart functionality.

#### Key Sections

**AppBar**
- Title: "Product Details"
- Cart badge showing item count (if cart has items)

**Image Carousel**
- PageView of product images
- Main product image + additional images
- Full-width, 400pt height
- Error handling with icon display
- Swipeable navigation between images

**Product Information**
- **Title Section**
  - Product name (large heading)
  - Category name (secondary text)
  - Price badge (right-aligned)
  
- **Stock Status**
  - Green container if in stock: "{quantity} items in stock"
  - Red container if out of stock: "Out of stock"
  
- **Description**
  - Full product description text
  
- **Materials** (conditional)
  - Shows only if `materials` is not empty
  - Detailed materials information
  
- **Care Instructions** (conditional)
  - Shows only if `care` is not empty
  - Care and maintenance guidelines

#### Add to Cart Section (Sticky Bottom)
- **Quantity Selector**
  - Minus button (disabled at 1)
  - Quantity display
  - Plus button (disabled at stock limit)
  
- **Add to Cart Button**
  - Shows loading spinner while processing
  - Disabled when no stock
  - Shows success SnackBar on completion
  - Shows error SnackBar on failure

**Null Safety Bug Note:**
⚠️ Lines 193 & 212 have null safety issues:
```dart
if (product.materials?.isNotEmpty ?? false)  // ✅ Correct pattern
if (product.care?.isNotEmpty ?? false)       // ✅ Correct pattern
```

#### UI Layout
```
┌────────────────────────────────┐
│  AppBar with cart badge        │
├────────────────────────────────┤
│     [Image Carousel]           │
│  ◄ [   Main Image   ] ►        │
│                                │
├────────────────────────────────┤
│ Product Name                   │
│ Category          $ Price      │
│ ✅ 5 in stock                  │
│                                │
│ Description                    │
│ Lorem ipsum dolor sit amet...  │
│                                │
│ Materials                      │
│ Premium leather...             │
│                                │
│ Care Instructions              │
│ Hand wash only...              │
├────────────────────────────────┤
│ [- 1 +]  [🛍️ Add to Cart]      │ ← Fixed bottom
└────────────────────────────────┘
```

#### Cart Integration
- Watches `cartNotifierProvider` for item count
- Updates quantity in cart on button press
- Shows appropriate success/error messages

---

## 🛒 Shopping & Checkout

### 6. **CartScreen** (`lib/screens/cart/cart_screen.dart`)

#### Purpose
Shopping cart management. Review and modify items before checkout.

#### Empty State
- Large shopping bag icon
- "Your cart is empty" message
- "Continue Shopping" button → `/products`

#### Cart Items List
- Scrollable list of cart items
- Each item displays as `CartItemTile`

**CartItemTile Component**
```
┌─────────────────────────────────┐
│ [Image]  Product Name      Qty  │
│ 100x100  $99.99           [-1+] │
│          Price per item   Remove │
│          Subtotal: $298.97      │
└─────────────────────────────────┘
```

- **Product Image**
  - 100x100pt square
  - Rounded corners (8pt)
  - Network image with error handling
  
- **Product Info**
  - Name (up to 2 lines, ellipsis)
  - Price per unit
  
- **Quantity Controls**
  - Minus button (disabled at 1)
  - Quantity display (centered)
  - Plus button (no limit, user can over-order)
  
- **Remove Button**
  - Text button in error color
  - Removes item from cart
  
- **Subtotal**
  - Price × Quantity
  - Right-aligned

#### Order Summary Card
- Displays when cart has items
- **Subtotal**: Sum of all items
- **Shipping**: "FREE" (in green)
- **Total**: Grand total (in golden color, bold)

#### Checkout Button (Fixed Bottom)
- "Proceed to Checkout"
- Sticky positioned at bottom
- Navigates to `/checkout`
- Only visible when cart has items

#### Error Handling
- Quantity changes show error SnackBar on failure
- Item removal shows error SnackBar on failure

---

### 7. **CheckoutScreen** (`lib/screens/checkout/checkout_screen.dart`)

#### Purpose
Finalize purchase with shipping and payment information.

#### Order Summary Card
- **Items List**
  - Shows each cart item: "Product Name x{quantity}"
  - Item subtotal: "$XX.XX"
  
- **Total Amount**
  - Displayed in golden color
  - Bold, large heading

#### Shipping Address Form
- **Street Address**
  - Required field
  - Text input with location icon
  
- **City** (Row with State)
  - Required field
  - Half-width in row
  
- **State**
  - Required field
  - Half-width in row
  
- **ZIP Code**
  - Required field
  - Full-width input

#### Payment Method Selection
- **Credit Card** (default)
  - "Visa, Mastercard, American Express"
  
- **Debit Card**
  - "Debit card payments"
  
- **PayPal**
  - "PayPal account"

Radio buttons for selection. Only one method allowed.

#### Terms & Conditions
- CheckboxListTile
- "I agree to the terms and conditions"
- Required to place order
- Shows warning SnackBar if unchecked

#### Place Order Button
- Shows loading spinner while processing
- Disabled while loading
- Success: Navigates to `/orders/{orderId}`
- Error: Shows error message in red text below button

#### Form Validation
- All address fields required
- Terms must be accepted
- Real-time validation with helpful messages

#### UI Layout
```
┌────────────────────────────────┐
│  Order Summary                 │
│  ├─ Product 1 x2      $199.98  │
│  ├─ Product 2 x1      $99.99   │
│  └─ Total:            $299.97  │
│                                │
│  Shipping Address              │
│  [Street Address]              │
│  [City]        [State]         │
│  [ZIP Code]                    │
│                                │
│  Payment Method                │
│  ○ Credit Card                 │
│  ○ Debit Card                  │
│  ○ PayPal                      │
│                                │
│  ☑ I agree to terms            │
│                                │
│  [Place Order]                 │
│  Error message (if any)        │
└────────────────────────────────┘
```

---

### 8. **OrdersScreen** (`lib/screens/orders/orders_screen.dart`)

#### Purpose
View all user orders with status tracking.

#### Empty State
- Large receipt icon
- "No orders yet" message
- "Start Shopping" button → `/products`

#### Orders List
- Scrollable list of order cards
- Separated by 12pt spacing
- Each card tappable to view details

**OrderCard Component**
```
┌──────────────────────────────────┐
│ Order #12345678    [Status]      │
│ Feb 10, 2026                     │
│                                  │
│ 2 item(s)                        │
│ Total           $299.97          │
└──────────────────────────────────┘
```

- **Order Header**
  - Order ID (shortened to first 8 chars)
  - Creation date formatted as "MMM dd, yyyy"
  - Status badge (colored by status)
  
- **Order Details**
  - Item count: "X item(s)"
  - Divider line
  
- **Total Amount**
  - Formatted currency
  - Golden color, bold

#### Status Colors
| Status | Color |
|--------|-------|
| pending | Orange |
| processing | Blue |
| shipped | Indigo |
| delivered | Green (success) |
| cancelled | Red (error) |

#### Navigation
- Tapping card → `/orders/{orderId}`

#### Loading State
- Centered CircularProgressIndicator

#### Error State
- Error icon
- Error message display
- "Retry" button to refresh

---

### 9. **OrderDetailScreen** (`lib/screens/orders/order_detail_screen.dart`)

#### Purpose
Comprehensive order details with full tracking information.

#### Order Header Card
- **Order Info**
  - Order number (shortened)
  - Date and time formatted: "MMMM dd, yyyy - hh:mm a"
  - Status badge (colored)
  
- **Status Timeline**
  - Visual step indicator
  - 4 steps: Order Placed → Processing → Shipped → Delivered
  - Completed steps show checkmark (golden circle)
  - Current step highlighted in golden
  - Connecting vertical line between steps
  - Current step shows "Current Status" label

**Status Timeline Visualization**
```
✓ Order Placed
│
✓ Processing
│
● Shipped ← Current Status
│
○ Delivered
```

#### Shipping Address Section
- Card containing shipping address
- Plain text address display
- "N/A" if not provided

#### Order Items Card
- List of items in order
- Each item shows:
  - **Product Image** (80x80pt square)
  - **Product Details**
    - Product name
    - Quantity: "Qty: X"
    - Price per unit (secondary text)
  - **Subtotal** (right-aligned, golden)

#### Payment Method Card
- Shows selected payment method
- Displays as human-readable text:
  - `credit_card` → "Credit Card"
  - `debit_card` → "Debit Card"
  - `paypal` → "PayPal"

#### Order Total
- Large heading
- Amount in golden, bold
- Displayed in items card footer

#### Continue Shopping Button
- Navigates to `/products`

#### UI Layout
```
┌────────────────────────────────┐
│ Order #12345678  [Delivered]   │
│ February 10, 2026 - 2:30 PM    │
│                                │
│ Order Status                   │
│ ✓ Order Placed                 │
│ ✓ Processing                   │
│ ✓ Shipped                      │
│ ● Delivered ← Current          │
│                                │
│ Shipping Address               │
│ 123 Main St, City, ST 12345    │
│                                │
│ Order Items                    │
│ [IMG] Product 1 x2             │
│       $99.99 each      $199.98 │
│ [IMG] Product 2 x1             │
│       $99.99 each      $99.99  │
│ ─────────────────────────────  │
│ Order Total               $299.97│
│                                │
│ Payment Method                 │
│ Credit Card                    │
│                                │
│ [Continue Shopping]            │
└────────────────────────────────┘
```

---

### 10. **ProfileScreen** (`lib/screens/profile/profile_screen.dart`)

#### Purpose
User account management and quick actions.

#### Profile Header Card
- **Avatar Circle**
  - 100x100pt circle
  - Shows user's first name initial (uppercase)
  - Golden border (2pt)
  - Surface color background
  
- **User Name**
  - Large heading
  - Centered
  
- **Email Address**
  - Secondary color text
  - Centered
  
- **Admin Badge** (Conditional)
  - Shows only if `isAdmin: true`
  - "Administrator" label
  - Golden background with low opacity
  - Rounded pill shape

#### Account Information Card
- **Email Row**
  - Label: "Email"
  - Value: User's email
  
- **Name Row**
  - Label: "Name"
  - Value: User's full name
  
- **Account Type Row**
  - Label: "Account Type"
  - Value: "Administrator" or "Customer"
  
- **Member Since Row**
  - Label: "Member Since"
  - Value: Account creation year

Each row separated by divider line.

#### Quick Actions Section
- **View Orders Button** (Outlined)
  - Receipt icon
  - Text: "View Orders"
  - Navigates to `/orders`
  
- **Continue Shopping Button** (Outlined)
  - Shopping bag icon
  - Text: "Continue Shopping"
  - Navigates to `/products`

#### Logout Button
- Elevated button with red background
- Logout icon
- Text: "Logout"
- Clears tokens and redirects to `/login`
- Shows error SnackBar if logout fails

#### UI Layout
```
┌────────────────────────────────┐
│          [Avatar: J]           │
│       John Doe                 │
│   john@example.com             │
│    [Administrator]             │
│                                │
│ Account Information            │
│ Email         john@example.com │
│ Name          John Doe         │
│ Account Type  Administrator    │
│ Member Since  2023             │
│                                │
│ Quick Actions                  │
│ [📋 View Orders]               │
│ [🛍️ Continue Shopping]         │
│                                │
│ [Logout]                       │
└────────────────────────────────┘
```

#### Navigation from Header
- ProfileScreen is accessible from HomeScreen and ProductDetailScreen
- Person icon in AppBar → Navigate to `/profile`

---

## 🎨 Visual Design System

### Colors
- **Primary**: Golden Yellow (`hsl(45, 100%, 50%)`)
- **Background**: Deep Black (`#000000`)
- **Surface**: Slightly lighter black for cards
- **Text Primary**: White
- **Text Secondary**: Light gray
- **Success**: Green
- **Error**: Red

### Typography
- **Font Family**: Alegreya (Serif) - *Currently missing, critical issue*
- **Display Small**: Headings
- **Headline Small**: Section titles
- **Label Large**: Card titles
- **Body Medium**: Regular text
- **Body Small**: Secondary text

### Spacing
- Large padding: 24pt
- Medium padding: 16pt
- Small padding: 12pt
- Tiny padding: 8pt

### Component Styles
- **Cards**: Elevated shadow, surface color background
- **Buttons**: Rounded corners, golden accent color
- **Icons**: Lucide React icons throughout
- **Badges**: Rounded pill shape, low-opacity backgrounds

---

## 🔄 State Management Overview

All screens use **Riverpod** for state management:

- `authStateProvider` - User authentication state
- `cartNotifierProvider` - Shopping cart management
- `productsProvider` - Product listing with pagination
- `productDetailsProvider` - Single product details
- `categoriesProvider` - Product categories
- `ordersProvider` - User orders list
- `orderDetailsProvider` - Single order details
- `checkoutNotifierProvider` - Checkout flow state

---

## 📊 Data Flow Summary

```
User Authentication
   ↓
HomeScreen (view categories & featured products)
   ↓
ProductListScreen (browse all products)
   ↓
ProductDetailScreen (view details & add to cart)
   ↓
CartScreen (review & modify cart)
   ↓
CheckoutScreen (enter shipping & payment)
   ↓
OrdersScreen (view order history)
   ↓
OrderDetailScreen (track order status)
   ↓
ProfileScreen (manage account)
```

---

## 📋 Responsive Design

All screens are optimized for:
- ✅ Mobile phones (360dp - 640dp width)
- ✅ Tablets (600dp - 1024dp width)
- ✅ Grid layouts adapt automatically
- ✅ Single column on mobile
- ✅ Multi-column on larger screens

---

## ⚠️ Known Issues by Screen

| Screen | Issue | Severity | Location |
|--------|-------|----------|----------|
| ProductDetailScreen | Null safety in materials check | 🟠 Major | Line 193 |
| ProductDetailScreen | Null safety in care check | 🟠 Major | Line 212 |
| All | Missing font assets | 🔴 Critical | pubspec.yaml |
| All | Empty asset directories | 🔴 Critical | assets/ |

---

## 🎯 Screen Testing Checklist

- [ ] LoginScreen - Form validation, auth flow
- [ ] SignupScreen - Registration, validation
- [ ] HomeScreen - Load categories, load featured products
- [ ] ProductListScreen - Search, filter by category, pagination
- [ ] ProductDetailScreen - Image carousel, add to cart
- [ ] CartScreen - Update quantities, remove items
- [ ] CheckoutScreen - Form validation, order creation
- [ ] OrdersScreen - Load user orders
- [ ] OrderDetailScreen - Status timeline display
- [ ] ProfileScreen - Display user info, logout

---

**End of Screen Descriptions**

