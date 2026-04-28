# Pricing Configuration

## Monetization Model: Subscription (IAP) + One-time Purchase

## Subscription Group
- **Group Name**: PrecondAI Premium
- **Group ID**: PrecondAI_Premium

## Subscription Tiers

### 1. Monthly Subscription
- **Reference Name**: Monthly Premium
- **Product ID**: `com.zzoutuo.PrecondAI.monthly`
- **Price**: $2.99 per month
- **Display Name**: PrecondAI Monthly
- **Description**: Smart EV climate with weather AI
- **Localization**: English (US)
- **Free Trial**: 7 days

### 2. Yearly Subscription
- **Reference Name**: Yearly Premium
- **Product ID**: `com.zzoutuo.PrecondAI.yearly`
- **Price**: $19.99 per year (44% savings vs monthly)
- **Display Name**: PrecondAI Yearly
- **Description**: Best value smart EV climate
- **Localization**: English (US)
- **Free Trial**: 1 month (30 days)

### 3. Lifetime Purchase (One-time)
- **Reference Name**: Lifetime Access
- **Product ID**: `com.zzoutuo.PrecondAI.lifetime`
- **Price**: $49.99 one-time purchase
- **Display Name**: PrecondAI Lifetime
- **Description**: Pay once, use forever
- **Localization**: English (US)
- **Note**: No ongoing costs, all premium features forever

## Free Tier Features
- Remote start/stop preconditioning
- 1 vehicle
- 1 schedule
- Manual time-based scheduling
- Basic notifications

## Premium Features (Subscription or Lifetime Required)
- Weather-aware smart scheduling (core differentiator)
- Unlimited schedules
- Multi-vehicle support (up to 3)
- Calendar integration (Google/Apple Calendar)
- Departure reminder notifications
- Battery safety protection (unplugged preconditioning)
- Priority customer support

## Free Trial
- **Monthly**: 7 days free trial
- **Yearly**: 1 month (30 days) free trial
- **Lifetime**: No trial (one-time purchase)
- **Type**: Free trial (auto-converts to paid)

## Pricing Comparison

| Plan | Price | Trial | Equivalent Monthly | Savings |
|------|-------|-------|-------------------|---------|
| Monthly | $2.99/mo | 7 days | $2.99 | - |
| Yearly | $19.99/yr | 1 month | $1.67/mo | 44% |
| Lifetime | $49.99 once | None | ~$0.83/mo (5 years) | 72% |

## Policy Pages Required
- Support Page: ✅ (Must include subscription management info)
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist
- [x] Auto-renewal terms included in Terms
- [x] Cancellation instructions included
- [x] Pricing clearly stated
- [x] Free trial terms included (7 days for monthly, 1 month for yearly)
- [x] Restore purchases functionality implemented
- [x] Lifetime purchase option available
