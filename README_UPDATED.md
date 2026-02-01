# MOBILE_FLUTTER_1771020311_TRAN_HAU_HUAN

**Submission Format**: `MOBILE_FLUTTER_1771020311_TRAN_HAU_HUAN`

## 📋 Project Structure

```
mobile_flutter/
├── Backend/                    # ASP.NET Core Web API
│   ├── Controllers/
│   │   ├── AuthController.cs           # Login/Register
│   │   ├── WalletController.cs         # Topup/Balance
│   │   ├── BookingController.cs        # Courts/Bookings
│   │   └── AdminController.cs          # Revenue report
│   ├── Services/
│   │   └── WalletService.cs            # Business logic
│   ├── Entities/                       # Database models
│   ├── DTOs/                           # Data transfer objects
│   ├── Data/
│   │   └── ApplicationDbContext.cs     # EF Core context
│   ├── Migrations/                     # Database migrations
│   ├── Program.cs                      # Configuration
│   └── PCM.Backend.csproj
│
├── Mobile/                     # Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart                   # App entry point
│   │   ├── screens/
│   │   │   ├── login_screen.dart       # Login
│   │   │   ├── home_screen.dart        # Main dashboard
│   │   │   ├── wallet_screen.dart      # Wallet/Topup
│   │   │   ├── courts_screen.dart      # Browse courts
│   │   │   ├── bookings_screen.dart    # User bookings
│   │   │   └── admin_screen.dart       # Admin revenue
│   │   ├── services/
│   │   │   └── api_service.dart        # API client
│   │   └── models/                     # Data models
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
│
└── README_UPDATED.md
```

## 🎯 Demo Flow

**Sequence**: Mở app → Đăng nhập → Nạp tiền → Ví tăng → Đặt sân → Ví giảm → Admin kiểm tra doanh thu

### Step-by-step:
1. ✅ **Open App** - Show login screen
2. ✅ **Login** - API: `POST /api/auth/login`
3. ✅ **View Wallet** - Show balance (0 VND)
4. ✅ **Topup Money** - API: `POST /api/wallet/topup` (500,000 VND)
5. ✅ **Check Wallet Increased** - Balance: 500,000 VND
6. ✅ **View Courts** - API: `GET /api/booking/courts`
7. ✅ **Book Court** - API: `POST /api/booking` (100,000 VND)
8. ✅ **Check Wallet Decreased** - Balance: 400,000 VND
9. ✅ **Admin Check Revenue** - API: `GET /api/admin/revenue`

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/login` - Login
- `POST /api/auth/register` - Register

### Wallet
- `GET /api/wallet/balance/{userId}` - Check balance
- `POST /api/wallet/topup` - Add money
- `GET /api/wallet/transactions/{userId}` - Transaction history

### Booking
- `GET /api/booking/courts` - List courts
- `POST /api/booking` - Create booking
- `GET /api/booking/user/{userId}` - User bookings
- `DELETE /api/booking/{bookingId}` - Cancel booking

### Admin
- `GET /api/admin/revenue` - Revenue report
- `GET /api/admin/bookings` - All bookings
- `GET /api/admin/wallets` - Wallet stats
- `GET /api/admin/users` - User stats
- `GET /api/admin/transactions` - Transactions

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| Backend | ASP.NET Core 10.0 |
| Database | SQL Server + EF Core |
| Mobile | Flutter 3.0+ |
| API Style | RESTful with JSON |

## 🚀 Quick Start

### Backend Setup

```bash
cd Backend
dotnet restore
dotnet ef database update
dotnet run
```

API runs at: `http://localhost:5000`

### Mobile Setup

```bash
cd Mobile
flutter pub get
flutter run
```

## 📝 Test Account

**Email**: `testuser@example.com`  
**Password**: `password123`

## ✅ Features Implemented

- ✅ User Authentication (Login/Register)
- ✅ Wallet Management (Balance, Topup, History)
- ✅ Court Booking System
- ✅ Admin Revenue Reports
- ✅ CORS enabled
- ✅ Database with migrations
- ✅ Error handling
- ✅ Proper HTTP status codes

## 📱 Mobile Screens

1. **Login** - Email/Password
2. **Home** - Dashboard with navigation
3. **Wallet** - Balance & Topup
4. **Courts** - Browse & Book
5. **Bookings** - User reservations
6. **Admin** - Revenue reports

---

**Submission ID**: `MOBILE_FLUTTER_1771020311_TRAN_HAU_HUAN`
