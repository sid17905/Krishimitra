class MandiPriceDetail {
  final int price;
  final String change;
  final bool isUp;

  const MandiPriceDetail({
    required this.price,
    required this.change,
    required this.isUp,
  });
}

class CropStaticMarketInfo {
  final String id;
  final String name;
  final String nameHi;
  final String unit;
  final Map<String, MandiPriceDetail> mandiPrices;
  final Map<String, List<Map<String, dynamic>>> trends;
  final List<Map<String, dynamic>> forecast;
  final List<Map<String, dynamic>> nearbyMandis;
  final String sellingTip;
  final String sellingTipHi;

  const CropStaticMarketInfo({
    required this.id,
    required this.name,
    required this.nameHi,
    required this.unit,
    required this.mandiPrices,
    required this.trends,
    required this.forecast,
    required this.nearbyMandis,
    required this.sellingTip,
    required this.sellingTipHi,
  });
}

class MarketDataRepository {
  static const List<String> crops = [
    'Wheat',
    'Rice',
    'Maize',
    'Soybean',
    'Cotton',
    'Mustard',
    'Potato',
  ];

  static const List<String> mandis = [
    'Ghazipur Mandi (UP)',
    'Azadpur Mandi (Delhi)',
    'Kanpur Mandi (UP)',
    'Varanasi Mandi (UP)',
    'Patna APMC (Bihar)',
    'Indore APMC (MP)',
    'Pune APMC (Maharashtra)',
    'Nashik Market (Maharashtra)',
    'Khanna Mandi (Punjab)',
    'Karnal Mandi (Haryana)',
    'Jaipur APMC (Rajasthan)',
    'Rajkot Mandi (Gujarat)',
    'Kandi APMC (West Bengal)',
  ];

  static const Map<String, CropStaticMarketInfo> cropData = {
    'Wheat': CropStaticMarketInfo(
      id: 'Wheat',
      name: 'Wheat',
      nameHi: 'गेहूं',
      unit: '₹/quintal',
      mandiPrices: {
        'Ghazipur Mandi (UP)': MandiPriceDetail(price: 2340, change: '+2.5%', isUp: true),
        'Azadpur Mandi (Delhi)': MandiPriceDetail(price: 2380, change: '+1.5%', isUp: true),
        'Kanpur Mandi (UP)': MandiPriceDetail(price: 2290, change: '+0.8%', isUp: true),
        'Varanasi Mandi (UP)': MandiPriceDetail(price: 2320, change: '+1.4%', isUp: true),
        'Patna APMC (Bihar)': MandiPriceDetail(price: 2280, change: '+1.1%', isUp: true),
        'Indore APMC (MP)': MandiPriceDetail(price: 2450, change: '+2.2%', isUp: true),
        'Pune APMC (Maharashtra)': MandiPriceDetail(price: 2420, change: '+0.9%', isUp: true),
        'Nashik Market (Maharashtra)': MandiPriceDetail(price: 2410, change: '+1.1%', isUp: true),
        'Khanna Mandi (Punjab)': MandiPriceDetail(price: 2375, change: '+1.8%', isUp: true),
        'Karnal Mandi (Haryana)': MandiPriceDetail(price: 2360, change: '+1.2%', isUp: true),
        'Jaipur APMC (Rajasthan)': MandiPriceDetail(price: 2390, change: '+1.7%', isUp: true),
        'Rajkot Mandi (Gujarat)': MandiPriceDetail(price: 2440, change: '+2.0%', isUp: true),
        'Kandi APMC (West Bengal)': MandiPriceDetail(price: 2750, change: '+2.8%', isUp: true),
      },
      trends: {
        '7D': [
          {'label': 'Mon', 'price': 2180},
          {'label': 'Tue', 'price': 2220},
          {'label': 'Wed', 'price': 2250},
          {'label': 'Thu', 'price': 2280},
          {'label': 'Fri', 'price': 2260},
          {'label': 'Sat', 'price': 2300},
          {'label': 'Sun', 'price': 2340},
        ],
        '30D': [
          {'label': 'W1', 'price': 2100},
          {'label': 'W2', 'price': 2180},
          {'label': 'W3', 'price': 2250},
          {'label': 'W4', 'price': 2340},
        ],
        '90D': [
          {'label': 'Jun', 'price': 1950},
          {'label': 'Jul', 'price': 2000},
          {'label': 'Aug', 'price': 2180},
          {'label': 'Sep', 'price': 2340},
        ],
      },
      forecast: [
        {'label': 'Today', 'price': 2340, 'change': '+2.5%', 'isUp': true},
        {'label': 'Tomorrow', 'price': 2380, 'change': '+1.7%', 'isUp': true},
        {'label': 'Week', 'price': 2400, 'change': '+0.8%', 'isUp': true},
      ],
      nearbyMandis: [
        {'name': 'Azadpur Mandi', 'price': '₹2,380', 'change': '+1.5%'},
        {'name': 'Kanpur Mandi', 'price': '₹2,290', 'change': '+0.8%'},
        {'name': 'Agra Mandi', 'price': '₹2,310', 'change': '+1.2%'},
      ],
      sellingTip: 'Selling Tip: High procurement demand. Best to sell in 2 weeks.',
      sellingTipHi: 'बेचने का सुझाव: खरीद मांग अधिक है। 2 सप्ताह में बेचना सबसे अच्छा।',
    ),
    'Rice': CropStaticMarketInfo(
      id: 'Rice',
      name: 'Rice',
      nameHi: 'चावल (धान)',
      unit: '₹/quintal',
      mandiPrices: {
        'Ghazipur Mandi': MandiPriceDetail(price: 2220, change: '+1.8%', isUp: true),
        'Azadpur Mandi': MandiPriceDetail(price: 2260, change: '+2.1%', isUp: true),
        'Pune APMC': MandiPriceDetail(price: 2350, change: '+0.5%', isUp: true),
        'Kanpur Mandi': MandiPriceDetail(price: 2190, change: '+1.2%', isUp: true),
        'Pune Market': MandiPriceDetail(price: 2340, change: '+0.4%', isUp: true),
      },
      trends: {
        '7D': [
          {'label': 'Mon', 'price': 2150},
          {'label': 'Tue', 'price': 2160},
          {'label': 'Wed', 'price': 2180},
          {'label': 'Thu', 'price': 2190},
          {'label': 'Fri', 'price': 2200},
          {'label': 'Sat', 'price': 2210},
          {'label': 'Sun', 'price': 2220},
        ],
        '30D': [
          {'label': 'W1', 'price': 2080},
          {'label': 'W2', 'price': 2120},
          {'label': 'W3', 'price': 2180},
          {'label': 'W4', 'price': 2220},
        ],
        '90D': [
          {'label': 'Jun', 'price': 1980},
          {'label': 'Jul', 'price': 2040},
          {'label': 'Aug', 'price': 2120},
          {'label': 'Sep', 'price': 2220},
        ],
      },
      forecast: [
        {'label': 'Today', 'price': 2220, 'change': '+1.8%', 'isUp': true},
        {'label': 'Tomorrow', 'price': 2250, 'change': '+1.4%', 'isUp': true},
        {'label': 'Week', 'price': 2300, 'change': '+2.2%', 'isUp': true},
      ],
      nearbyMandis: [
        {'name': 'Varanasi Mandi', 'price': '₹2,240', 'change': '+1.4%'},
        {'name': 'Patna APMC', 'price': '₹2,210', 'change': '+0.9%'},
        {'name': 'Chandauli Mandi', 'price': '₹2,260', 'change': '+2.0%'},
      ],
      sellingTip: 'Selling Tip: Hold stock for mid-season price peak.',
      sellingTipHi: 'बेचने का सुझाव: मध्य-मौसम के चरम मूल्य के लिए स्टॉक रोकें।',
    ),
    'Maize': CropStaticMarketInfo(
      id: 'Maize',
      name: 'Maize',
      nameHi: 'मक्का',
      unit: '₹/quintal',
      mandiPrices: {
        'Ghazipur Mandi': MandiPriceDetail(price: 1920, change: '-0.8%', isUp: false),
        'Azadpur Mandi': MandiPriceDetail(price: 1980, change: '+0.5%', isUp: true),
        'Pune APMC': MandiPriceDetail(price: 2040, change: '+1.2%', isUp: true),
        'Kanpur Mandi': MandiPriceDetail(price: 1890, change: '-1.1%', isUp: false),
        'Pune Market': MandiPriceDetail(price: 2020, change: '+0.8%', isUp: true),
      },
      trends: {
        '7D': [
          {'label': 'Mon', 'price': 1960},
          {'label': 'Tue', 'price': 1950},
          {'label': 'Wed', 'price': 1940},
          {'label': 'Thu', 'price': 1930},
          {'label': 'Fri', 'price': 1925},
          {'label': 'Sat', 'price': 1915},
          {'label': 'Sun', 'price': 1920},
        ],
        '30D': [
          {'label': 'W1', 'price': 2010},
          {'label': 'W2', 'price': 1980},
          {'label': 'W3', 'price': 1950},
          {'label': 'W4', 'price': 1920},
        ],
        '90D': [
          {'label': 'Jun', 'price': 1820},
          {'label': 'Jul', 'price': 1890},
          {'label': 'Aug', 'price': 1960},
          {'label': 'Sep', 'price': 1920},
        ],
      },
      forecast: [
        {'label': 'Today', 'price': 1920, 'change': '-0.8%', 'isUp': false},
        {'label': 'Tomorrow', 'price': 1940, 'change': '+1.0%', 'isUp': true},
        {'label': 'Week', 'price': 1980, 'change': '+3.1%', 'isUp': true},
      ],
      nearbyMandis: [
        {'name': 'Gorakhpur Mandi', 'price': '₹1,940', 'change': '+0.5%'},
        {'name': 'Jaunpur Mandi', 'price': '₹1,910', 'change': '-0.3%'},
        {'name': 'Ballia Mandi', 'price': '₹1,890', 'change': '-1.0%'},
      ],
      sellingTip: 'Selling Tip: Poultry feed industrial demand projected to rise next week.',
      sellingTipHi: 'बेचने का सुझाव: अगले हफ्ते पोल्ट्री फीड की मांग बढ़ने की उम्मीद है।',
    ),
    'Soybean': CropStaticMarketInfo(
      id: 'Soybean',
      name: 'Soybean',
      nameHi: 'सोयाबीन',
      unit: '₹/quintal',
      mandiPrices: {
        'Ghazipur Mandi': MandiPriceDetail(price: 4450, change: '+3.1%', isUp: true),
        'Azadpur Mandi': MandiPriceDetail(price: 4520, change: '+2.8%', isUp: true),
        'Pune APMC': MandiPriceDetail(price: 4650, change: '+3.5%', isUp: true),
        'Kanpur Mandi': MandiPriceDetail(price: 4400, change: '+2.2%', isUp: true),
        'Pune Market': MandiPriceDetail(price: 4620, change: '+3.0%', isUp: true),
      },
      trends: {
        '7D': [
          {'label': 'Mon', 'price': 4200},
          {'label': 'Tue', 'price': 4250},
          {'label': 'Wed', 'price': 4310},
          {'label': 'Thu', 'price': 4360},
          {'label': 'Fri', 'price': 4390},
          {'label': 'Sat', 'price': 4420},
          {'label': 'Sun', 'price': 4450},
        ],
        '30D': [
          {'label': 'W1', 'price': 4050},
          {'label': 'W2', 'price': 4180},
          {'label': 'W3', 'price': 4320},
          {'label': 'W4', 'price': 4450},
        ],
        '90D': [
          {'label': 'Jun', 'price': 3850},
          {'label': 'Jul', 'price': 4020},
          {'label': 'Aug', 'price': 4250},
          {'label': 'Sep', 'price': 4450},
        ],
      },
      forecast: [
        {'label': 'Today', 'price': 4450, 'change': '+3.1%', 'isUp': true},
        {'label': 'Tomorrow', 'price': 4510, 'change': '+1.3%', 'isUp': true},
        {'label': 'Week', 'price': 4620, 'change': '+2.4%', 'isUp': true},
      ],
      nearbyMandis: [
        {'name': 'Indore Mandi', 'price': '₹4,680', 'change': '+3.8%'},
        {'name': 'Ujjain Mandi', 'price': '₹4,610', 'change': '+2.9%'},
        {'name': 'Nagpur APMC', 'price': '₹4,590', 'change': '+2.5%'},
      ],
      sellingTip: 'Selling Tip: High crushing plant demand. Sell within 7-10 days.',
      sellingTipHi: 'बेचने का सुझाव: क्रशिंग प्लांट की मांग अधिक है। 7-10 दिनों में बेचें।',
    ),
    'Cotton': CropStaticMarketInfo(
      id: 'Cotton',
      name: 'Cotton',
      nameHi: 'कपास',
      unit: '₹/quintal',
      mandiPrices: {
        'Ghazipur Mandi': MandiPriceDetail(price: 7050, change: '+1.1%', isUp: true),
        'Azadpur Mandi': MandiPriceDetail(price: 7180, change: '+1.6%', isUp: true),
        'Pune APMC': MandiPriceDetail(price: 7350, change: '+2.0%', isUp: true),
        'Kanpur Mandi': MandiPriceDetail(price: 6980, change: '+0.9%', isUp: true),
        'Pune Market': MandiPriceDetail(price: 7300, change: '+1.8%', isUp: true),
      },
      trends: {
        '7D': [
          {'label': 'Mon', 'price': 6900},
          {'label': 'Tue', 'price': 6940},
          {'label': 'Wed', 'price': 6980},
          {'label': 'Thu', 'price': 7010},
          {'label': 'Fri', 'price': 7020},
          {'label': 'Sat', 'price': 7040},
          {'label': 'Sun', 'price': 7050},
        ],
        '30D': [
          {'label': 'W1', 'price': 6750},
          {'label': 'W2', 'price': 6880},
          {'label': 'W3', 'price': 6990},
          {'label': 'W4', 'price': 7050},
        ],
        '90D': [
          {'label': 'Jun', 'price': 6400},
          {'label': 'Jul', 'price': 6650},
          {'label': 'Aug', 'price': 6890},
          {'label': 'Sep', 'price': 7050},
        ],
      },
      forecast: [
        {'label': 'Today', 'price': 7050, 'change': '+1.1%', 'isUp': true},
        {'label': 'Tomorrow', 'price': 7120, 'change': '+1.0%', 'isUp': true},
        {'label': 'Week', 'price': 7250, 'change': '+1.8%', 'isUp': true},
      ],
      nearbyMandis: [
        {'name': 'Rajkot Mandi', 'price': '₹7,380', 'change': '+2.2%'},
        {'name': 'Akola APMC', 'price': '₹7,290', 'change': '+1.9%'},
        {'name': 'Yavatmal Mandi', 'price': '₹7,210', 'change': '+1.4%'},
      ],
      sellingTip: 'Selling Tip: Mill procurement active. Long-staple commands premium.',
      sellingTipHi: 'बेचने का सुझाव: मिल खरीद सक्रिय है। लंबे रेशे पर प्रीमियम मिल रहा है।',
    ),
    'Mustard': CropStaticMarketInfo(
      id: 'Mustard',
      name: 'Mustard',
      nameHi: 'सरसों',
      unit: '₹/quintal',
      mandiPrices: {
        'Ghazipur Mandi': MandiPriceDetail(price: 5320, change: '+2.3%', isUp: true),
        'Azadpur Mandi': MandiPriceDetail(price: 5480, change: '+2.7%', isUp: true),
        'Pune APMC': MandiPriceDetail(price: 5520, change: '+1.5%', isUp: true),
        'Kanpur Mandi': MandiPriceDetail(price: 5280, change: '+1.8%', isUp: true),
        'Pune Market': MandiPriceDetail(price: 5500, change: '+1.4%', isUp: true),
      },
      trends: {
        '7D': [
          {'label': 'Mon', 'price': 5150},
          {'label': 'Tue', 'price': 5190},
          {'label': 'Wed', 'price': 5220},
          {'label': 'Thu', 'price': 5270},
          {'label': 'Fri', 'price': 5290},
          {'label': 'Sat', 'price': 5310},
          {'label': 'Sun', 'price': 5320},
        ],
        '30D': [
          {'label': 'W1', 'price': 4980},
          {'label': 'W2', 'price': 5100},
          {'label': 'W3', 'price': 5230},
          {'label': 'W4', 'price': 5320},
        ],
        '90D': [
          {'label': 'Jun', 'price': 4750},
          {'label': 'Jul', 'price': 4920},
          {'label': 'Aug', 'price': 5140},
          {'label': 'Sep', 'price': 5320},
        ],
      },
      forecast: [
        {'label': 'Today', 'price': 5320, 'change': '+2.3%', 'isUp': true},
        {'label': 'Tomorrow', 'price': 5380, 'change': '+1.1%', 'isUp': true},
        {'label': 'Week', 'price': 5490, 'change': '+2.0%', 'isUp': true},
      ],
      nearbyMandis: [
        {'name': 'Bharatpur Mandi', 'price': '₹5,520', 'change': '+2.9%'},
        {'name': 'Alwar Mandi', 'price': '₹5,460', 'change': '+2.4%'},
        {'name': 'Jaipur APMC', 'price': '₹5,500', 'change': '+2.5%'},
      ],
      sellingTip: 'Selling Tip: High oil content fetches ₹150+ premium. Good time to sell.',
      sellingTipHi: 'बेचने का सुझाव: उच्च तेल सामग्री पर ₹150+ प्रीमियम मिल रहा है। बेचने का अच्छा समय।',
    ),
    'Potato': CropStaticMarketInfo(
      id: 'Potato',
      name: 'Potato',
      nameHi: 'आलू',
      unit: '₹/quintal',
      mandiPrices: {
        'Ghazipur Mandi': MandiPriceDetail(price: 1380, change: '-1.5%', isUp: false),
        'Azadpur Mandi': MandiPriceDetail(price: 1520, change: '+0.8%', isUp: true),
        'Pune APMC': MandiPriceDetail(price: 1600, change: '+1.2%', isUp: true),
        'Kanpur Mandi': MandiPriceDetail(price: 1320, change: '-2.1%', isUp: false),
        'Pune Market': MandiPriceDetail(price: 1580, change: '+0.9%', isUp: true),
      },
      trends: {
        '7D': [
          {'label': 'Mon', 'price': 1420},
          {'label': 'Tue', 'price': 1410},
          {'label': 'Wed', 'price': 1395},
          {'label': 'Thu', 'price': 1390},
          {'label': 'Fri', 'price': 1385},
          {'label': 'Sat', 'price': 1375},
          {'label': 'Sun', 'price': 1380},
        ],
        '30D': [
          {'label': 'W1', 'price': 1490},
          {'label': 'W2', 'price': 1450},
          {'label': 'W3', 'price': 1410},
          {'label': 'W4', 'price': 1380},
        ],
        '90D': [
          {'label': 'Jun', 'price': 1250},
          {'label': 'Jul', 'price': 1380},
          {'label': 'Aug', 'price': 1460},
          {'label': 'Sep', 'price': 1380},
        ],
      },
      forecast: [
        {'label': 'Today', 'price': 1380, 'change': '-1.5%', 'isUp': false},
        {'label': 'Tomorrow', 'price': 1360, 'change': '-1.4%', 'isUp': false},
        {'label': 'Week', 'price': 1410, 'change': '+3.7%', 'isUp': true},
      ],
      nearbyMandis: [
        {'name': 'Farrukhabad Mandi', 'price': '₹1,280', 'change': '-2.5%'},
        {'name': 'Agra APMC', 'price': '₹1,340', 'change': '-1.8%'},
        {'name': 'Meerut Mandi', 'price': '₹1,420', 'change': '+0.2%'},
      ],
      sellingTip: 'Selling Tip: Cold storage releases high. Short-term dip, recovery in 3 weeks.',
      sellingTipHi: 'बेचने का सुझाव: कोल्ड स्टोरेज निकासी अधिक है। अल्पकालिक गिरावट, 3 सप्ताह में सुधार।',
    ),
  };

  static CropStaticMarketInfo getCropData(String crop) {
    return cropData[crop] ?? cropData['Wheat']!;
  }
}
