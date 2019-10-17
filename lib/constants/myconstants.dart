class PropaneConstants {
  static const String BACKGROUND_IMAGE = 'assets/images/gokwe.png';
  static const String APP_LOGO = 'assets/images/gokwe.png';
  static const String DEV_WEB = 'assets/images/web.jpg';
  static const String DRAWER_LOGO = 'assets/images/gokwe.png';

  static const String USER_COMPANY = 'company';
  static const String USER_ADMIN = 'admin';

  static const String PATH_POSTS = 'posts/';
  static const String PATH_LOGO = 'logos/';

  static const String TENDER_STATUS_WON = 'won';
  static const String TENDER_STATUS_PENDING = 'pending';
  static const String TENDER_STATUS_FINISHED = 'finished';

  static const String PRICE_CUSTOMER = 'customer price';
  static const String PRICE_CREDIT_SALES = 'credit sales price';
  static const String price_frenchise_with_cash_ = 'frenchise price';

  static const String USD = 'USD';
  static const String RTGS = 'RTGS';
  static const String ECOCASH = 'ECOCASH';
  static const String SWIPE = 'SWIPE';
  static const List<String> CURRENCY = [USD, RTGS, ECOCASH, SWIPE];

  static const String USER_ORDINARY = 'Direct Customers';
  static const String USER_FRENCHISE = 'Frenchise Order';
  static const String USER_CAGE = 'Cage Order';
  static const String CREDIT_SALE = 'Credit Sale';
  static const String CREDIT_SALE_REPAYMENT = 'Credit Sale Repayment';
  static const List<String> USER_TYPE = [USER_ORDINARY, USER_FRENCHISE];

  static const String SHOP_WHOLESALE = 'Wholesale';
  static const String SHOP_FRENCHISE = 'Frenchise';
  static const String SHOP_CAGE = 'Cage';
  static const List<String> SHOP_TYPE = [
    SHOP_FRENCHISE,
    SHOP_WHOLESALE,
    SHOP_CAGE
  ];

  static const String SALES_PERSON_WHOLESALE = 'Wholesale Sales Person';
  static const String SALES_PERSON_FRANCHISE = 'Franchise Sales Person';
  static const String SALES_PERSON_AT_CAGE = 'Company Cage Sales Person';

  static const String PRICE_ORDINARY = "Ordinary";
  static const String PRICE_SPECIAL = "Special";
  static const List<String> PRICE_TYPE = [PRICE_ORDINARY, PRICE_SPECIAL];

  //Ordinary
  static const String STATUS_PENDING = 'Pending';
  static const String STATUS_ATTENDING = 'Attending';
  static const String STATUS_RESOLVED = 'Resolved';
}
