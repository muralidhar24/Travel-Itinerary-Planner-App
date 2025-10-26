import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/destination.dart';

class DestinationService {
  static const String _favoritesKey = 'favorite_destinations';

  // Singleton pattern
  static final DestinationService _instance = DestinationService._internal();
  factory DestinationService() => _instance;
  DestinationService._internal();

  List<String> _favoriteIds = [];
  List<String> get favoriteIds => _favoriteIds;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey);
    if (favoritesJson != null) {
      _favoriteIds = List<String>.from(jsonDecode(favoritesJson));
    }
  }

  // Mock data - in real app, this would come from API
  List<Destination> getMockDestinations() {
    return [
      Destination(
        id: '1',
        name: 'Jaipur, Rajasthan',
        description: 'The Pink City famed for its palaces, forts, vibrant bazaars, and royal heritage.',
        imageUrl: 'https://wallpapers.com/images/hd/hawa-mahal-in-jaipur-q5ky7q0bhbrd9vbj.jpg',
        location: 'Jaipur, Rajasthan, India',
        latitude: 26.9124,
        longitude: 75.7873,
        category: 'City',
        rating: 4.8,
        tags: ['Culture', 'Heritage', 'Architecture', 'Food'],
        price: 120.0,
        isFavorite: _favoriteIds.contains('1'),
      ),
      Destination(
        id: '2',
        name: 'Goa Beaches',
        description: 'Sun-soaked beaches, lively nightlife, and a relaxed coastal lifestyle.',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/BeachFun.jpg/330px-BeachFun.jpg',
        location: 'Goa, India',
        latitude: 15.2993,
        longitude: 74.1240,
        category: 'Beach',
        rating: 4.7,
        tags: ['Beach', 'Nightlife', 'Relaxation', 'Food'],
        price: 90.0,
        isFavorite: _favoriteIds.contains('2'),
      ),
      Destination(
        id: '3',
        name: 'Munnar Tea Hills',
        description: 'Rolling tea plantations, misty mountains, and cool highland weather.',
        imageUrl: 'https://cf.bstatic.com/xdata/images/hotel/max1024x768/45002240.jpg?k=293de99cfa6d0d95ff33357d2b0d94d07d9d6c6c7724feb2678a78ac6be4e13d&o=&hp=1',
        location: 'Munnar, Kerala, India',
        latitude: 10.0889,
        longitude: 77.0595,
        category: 'Mountain',
        rating: 4.6,
        tags: ['Nature', 'Tea Estates', 'Mountains', 'Photography'],
        price: 70.0,
        isFavorite: _favoriteIds.contains('3'),
      ),
      Destination(
        id: '4',
        name: 'Varanasi Ghats',
        description: 'Spiritual capital on the Ganges with ancient ghats and sacred rituals.',
        imageUrl: 'https://tse2.mm.bing.net/th/id/OIP.KwF95sb4LNK4FlqPwhA4iQHaE8?cb=12&rs=1&pid=ImgDetMain&o=7&rm=3',
        location: 'Varanasi, Uttar Pradesh, India',
        latitude: 25.3176,
        longitude: 82.9739,
        category: 'City',
        rating: 4.5,
        tags: ['Spiritual', 'Culture', 'Heritage', 'Festivals'],
        price: 60.0,
        isFavorite: _favoriteIds.contains('4'),
      ),
      Destination(
        id: '5',
        name: 'Andaman Islands',
        description: 'Crystal-clear waters, coral reefs, and tranquil island escapes.',
        imageUrl: 'https://i2-prod.mirror.co.uk/incoming/article3240859.ece/ALTERNATES/s1227b/Govindnagar-Beach-part-of-the-Andaman-Islands.jpg',
        location: 'Andaman & Nicobar Islands, India',
        latitude: 11.7401,
        longitude: 92.6586,
        category: 'Island',
        rating: 4.9,
        tags: ['Scuba Diving', 'Beach', 'Adventure', 'Nature'],
        price: 150.0,
        isFavorite: _favoriteIds.contains('5'),
      ),
      Destination(
        id: '6',
        name: 'Rann of Kutch',
        description: 'Otherworldly white salt desert hosting the vibrant Rann Utsav festival.',
        imageUrl: 'https://tse3.mm.bing.net/th/id/OIP.o5_Lst5gYdyAVF36jBDYaAHaCs?cb=12&rs=1&pid=ImgDetMain&o=7&rm=3',
        location: 'Kutch, Gujarat, India',
        latitude: 23.7337,
        longitude: 69.8597,
        category: 'Desert',
        rating: 4.4,
        tags: ['Festival', 'Desert', 'Culture', 'Photography'],
        price: 80.0,
        isFavorite: _favoriteIds.contains('6'),
      ),
      Destination(
        id: '7',
        name: 'Araku Valley',
        description: 'Scenic valley with coffee plantations, waterfalls, and Borra Caves excursions.',
        imageUrl: 'https://blogs.tripzygo.in/wp-content/uploads/2025/03/things-to-do-in-araku-valley.jpg',
        location: 'Araku Valley, Andhra Pradesh, India',
        latitude: 18.3368,
        longitude: 82.8732,
        category: 'Mountain',
        rating: 4.5,
        tags: ['Coffee', 'Waterfalls', 'Caves', 'Nature'],
        price: 65.0,
        isFavorite: _favoriteIds.contains('7'),
      ),
      Destination(
        id: '8',
        name: 'Visakhapatnam Coast',
        description: 'Urban beachfront with Ramakrishna Beach, Kailasagiri Hill, and submarine museum.',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/4/44/Visakhapatnam_beach_road_from_Kailsagiri_hill.jpg',
        location: 'Visakhapatnam, Andhra Pradesh, India',
        latitude: 17.6868,
        longitude: 83.2185,
        category: 'Beach',
        rating: 4.3,
        tags: ['Beach', 'City', 'Museums', 'Scenic Views'],
        price: 75.0,
        isFavorite: _favoriteIds.contains('8'),
      ),
      Destination(
        id: '9',
        name: 'Lepakshi Temple',
        description: 'Architectural marvel featuring hanging pillar and intricate Vijayanagara carvings.',
        imageUrl: 'https://th.bing.com/th/id/R.2af329df57583dfa90969fda9155eac6?rik=7qfcO5m8xMwDKA&riu=http%3a%2f%2fcities2explore.com%2fwp-content%2fuploads%2f2023%2f04%2fLepakshi-Temple-Pillars-1024x576.jpg&ehk=84gkf59O3A6ul61HH9p9OwJORwxSMYq5nRg%2bgneAtbI%3d&risl=&pid=ImgRaw&r=0',
        location: 'Lepakshi, Andhra Pradesh, India',
        latitude: 13.8050,
        longitude: 77.6099,
        category: 'Heritage',
        rating: 4.6,
        tags: ['Temple', 'Architecture', 'Heritage', 'Art'],
        price: 55.0,
        isFavorite: _favoriteIds.contains('9'),
      ),
      Destination(
        id: '10',
        name: 'Papikondalu',
        description: 'River cruise through lush hills along the Godavari, ideal for nature photography.',
        imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRbJ5Nr3WGbmjoKSz5IvUCYcevn8MHZephpLGTqXheojCM9bDhyG6JUSJam9VXTg_dc16M&usqp=CAU',
        location: 'Godavari River, Andhra Pradesh, India',
        latitude: 17.4970,
        longitude: 81.7787,
        category: 'River',
        rating: 4.4,
        tags: ['River Cruise', 'Hills', 'Photography', 'Relaxation'],
        price: 60.0,
        isFavorite: _favoriteIds.contains('10'),
      ),
      Destination(
        id: '11',
        name: 'Kodaikanal',
        description: 'Serene hill station with lakes, forests, and misty viewpoints.',
        imageUrl: 'https://tse4.mm.bing.net/th/id/OIP.P3WuXgxBGzUeJKFMpryxJAHaEZ?cb=12&rs=1&pid=ImgDetMain&o=7&rm=3',
        location: 'Kodaikanal, Tamil Nadu, India',
        latitude: 10.2381,
        longitude: 77.4892,
        category: 'Mountain',
        rating: 4.7,
        tags: ['Hill Station', 'Lakes', 'Trekking', 'Relaxation'],
        price: 85.0,
        isFavorite: _favoriteIds.contains('11'),
      ),
      Destination(
        id: '12',
        name: 'Hampi Ruins',
        description: 'UNESCO-listed ruins showcasing Dravidian architecture and ancient bazaars.',
        imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTBh-hGSV3dWjO31MC7hjkdfI8cmssWaxNZY_Gm2-bgS1d0NxSEeSuaa5Z0Uy3XedbZVfc&usqp=CAU',
        location: 'Hampi, Karnataka, India',
        latitude: 15.3350,
        longitude: 76.4600,
        category: 'Heritage',
        rating: 4.8,
        tags: ['Heritage', 'Architecture', 'History', 'Photography'],
        price: 70.0,
        isFavorite: _favoriteIds.contains('12'),
      ),
      Destination(
        id: '13',
        name: 'Kaziranga National Park',
        description: 'Iconic sanctuary for one-horned rhinos, elephants, and vibrant birdlife.',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fe/Beauty_of_Kaziranga_National_Park.jpg/1200px-Beauty_of_Kaziranga_National_Park.jpg',
        location: 'Kaziranga, Assam, India',
        latitude: 26.5775,
        longitude: 93.1711,
        category: 'Forest',
        rating: 4.6,
        tags: ['Wildlife', 'Safari', 'Nature', 'Conservation'],
        price: 95.0,
        isFavorite: _favoriteIds.contains('13'),
      ),
      Destination(
        id: '14',
        name: 'Udaipur Lakes',
        description: 'Romantic city with palaces, sparkling lakes, and vibrant art scenes.',
        imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFWfPBiy8dc-yeVMQbo0D06x8xUHK--PVn4P6xkI6NCQp8khy7cXQci5jrl2QOm1JUV2I&usqp=CAU',
        location: 'Udaipur, Rajasthan, India',
        latitude: 24.5854,
        longitude: 73.7125,
        category: 'City',
        rating: 4.7,
        tags: ['Palaces', 'Lakes', 'Culture', 'Photography'],
        price: 110.0,
        isFavorite: _favoriteIds.contains('14'),
      ),
      Destination(
        id: '15',
        name: 'Rishikesh Adventure',
        description: 'Yoga capital offering river rafting, Ganga aarti, and Himalayan hikes.',
        imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQVXkhRgnPUH_rkPD0hiCm1Y209GANMZQnlzXPQJinAvwA1T49MsSvRN0SbTqRGO5IHi2E&usqp=CAU',
        location: 'Rishikesh, Uttarakhand, India',
        latitude: 30.0869,
        longitude: 78.2676,
        category: 'Adventure',
        rating: 4.5,
        tags: ['Rafting', 'Yoga', 'Mountains', 'Culture'],
        price: 80.0,
        isFavorite: _favoriteIds.contains('15'),
      ),
      Destination(
        id: '16',
        name: 'Tirupati Temple',
        description: 'Sacred hilltop shrine dedicated to Lord Venkateswara, drawing millions of pilgrims.',
        imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQMD1Xu6Lu0g-QySSIoUsN-0brj3t-hCpNXBmlLiw7yfOKaGrvBbox4GMWWv7Mk8VIuoN0&usqp=CAU',
        location: 'Tirupati, Andhra Pradesh, India',
        latitude: 13.6288,
        longitude: 79.4192,
        category: 'Pilgrimage',
        rating: 4.9,
        tags: ['Temple', 'Spiritual', 'Hilltop', 'Festivals'],
        price: 50.0,
        isFavorite: _favoriteIds.contains('16'),
      ),
      Destination(
        id: '17',
        name: 'Gandikota Canyon',
        description: 'Dramatic gorge nicknamed the Grand Canyon of India, perfect for sunsets and camping.',
        imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQrDMuQWdH46bhSnGo-wSIx3wHJI9C0fSUvGi37vUXA-5eMi_bBFHI29LzKlaU-kvYaAGQ&usqp=CAU',
        location: 'Gandikota, Andhra Pradesh, India',
        latitude: 14.8157,
        longitude: 78.2826,
        category: 'Adventure',
        rating: 4.6,
        tags: ['Canyon', 'Camping', 'Adventure', 'Photography'],
        price: 70.0,
        isFavorite: _favoriteIds.contains('17'),
      ),
      Destination(
        id: '18',
        name: 'Suryalanka Beach',
        description: 'Expansive golden beach ideal for relaxed getaways on the Bay of Bengal shoreline.',
        imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQLBTT6gz_jx8lRJMMWlehQa_MmXucXRcv9hZ2v-M--rWvZCv9xmGGjY_D0RAbqnF8CY7Q&usqp=CAU',
        location: 'Bapatla, Andhra Pradesh, India',
        latitude: 15.9042,
        longitude: 80.4672,
        category: 'Beach',
        rating: 4.2,
        tags: ['Beach', 'Sunsets', 'Relaxation', 'Weekend Getaway'],
        price: 55.0,
        isFavorite: _favoriteIds.contains('18'),
      ),
      Destination(
        id: '19',
        name: 'Horsley Hills',
        description: 'Cool hill retreat with viewpoints, ziplining, and evergreen forests.',
        imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS4m8QDXZTep-1e7FasMgr5Vr9Ufw7cnTJcY-v-fBbshsnSUmGBjzlg60djVDjMCy1FKGQ&usqp=CAU',
        location: 'Chittoor, Andhra Pradesh, India',
        latitude: 13.6519,
        longitude: 78.3870,
        category: 'Mountain',
        rating: 4.3,
        tags: ['Hill Station', 'Adventure', 'Views', 'Nature'],
        price: 65.0,
        isFavorite: _favoriteIds.contains('19'),
      ),
      Destination(
        id: '20',
        name: 'Amaravati Stupa',
        description: 'Historic Buddhist site featuring ancient relics, sculptures, and serene ambience.',
        imageUrl: 'https://farm1.staticflickr.com/159/401763671_108dd82aaf_z.jpg?zz=1',
        location: 'Amaravati, Andhra Pradesh, India',
        latitude: 16.5730,
        longitude: 80.3575,
        category: 'Heritage',
        rating: 4.4,
        tags: ['Buddhist', 'Heritage', 'Museums', 'History'],
        price: 60.0,
        isFavorite: _favoriteIds.contains('20'),
      ),
      Destination(
        id: '21',
        name: 'Coringa Mangrove Forest',
        description: 'Protected mangrove ecosystem ideal for birdwatching and eco-tourism.',
        imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS18sZ8cYaxHEOxuJSG4HY_MrMEykpt3gvmAcJM04afNRWv0l_nRahBm0XHHaEzI4JNGXs&usqp=CAU',
        location: 'Kakinada, Andhra Pradesh, India',
        latitude: 16.8332,
        longitude: 82.2935,
        category: 'Wildlife',
        rating: 4.3,
        tags: ['Mangroves', 'Birdwatching', 'Boat Ride', 'Eco-Tourism'],
        price: 75.0,
        isFavorite: _favoriteIds.contains('21'),
      ),
      Destination(
        id: '22',
        name: 'Belum Caves',
        description: 'Extensive underground cave network with stalactites and illuminated chambers.',
        imageUrl: 'https://tse4.mm.bing.net/th/id/OIP.-2QVQWnxhwiE7ntcXxDL6wHaEm?cb=12ucfimg=1&rs=1&pid=ImgDetMain&o=7&rm=3',
        location: 'Belum, Andhra Pradesh, India',
        latitude: 15.1139,
        longitude: 78.1067,
        category: 'Cave',
        rating: 4.5,
        tags: ['Caves', 'Geology', 'Adventure', 'Exploration'],
        price: 68.0,
        isFavorite: _favoriteIds.contains('22'),
      ),
      Destination(
        id: '23',
        name: 'Taj Mahal, Agra',
        description: 'Iconic white marble mausoleum and UNESCO World Heritage site, symbolizing eternal love.',
        imageUrl: 'https://i0.wp.com/landlopers.com/wp-content/uploads/2018/04/Taj-Mahal-India.jpg?fit=1854%2C1512&ssl=1',
        location: 'Agra, Uttar Pradesh, India',
        latitude: 27.1751,
        longitude: 78.0421,
        category: 'Culture',
        rating: 4.6,
        tags: ['Culture', 'Heritage', 'Architecture', 'Monument'],
        price: 120.0,
        isFavorite: _favoriteIds.contains('23'),
      ),
      Destination(
        id: '24',
        name: 'Old Delhi Food Walk',
        description: 'Guided stroll through Chandni Chowk savoring chaats, kebabs, and Mughlai delicacies in bustling bazaars.',
        imageUrl: 'https://tse2.mm.bing.net/th/id/OIP.G-LwLf7-ZOObXbrMDO8nrwHaEO?cb=12&w=768&h=439&rs=1&pid=ImgDetMain&o=7&rm=3',
        location: 'Delhi, India',
        latitude: 28.6562,
        longitude: 77.2410,
        category: 'Food',
        rating: 4.7,
        tags: ['Food', 'Street Food', 'Markets', 'Culture'],
        price: 65.0,
        isFavorite: _favoriteIds.contains('24'),
      ),
      Destination(
        id: '25',
        name: 'Hyderabad Biryani Circuit',
        description: 'Curated tour of iconic eateries serving Hyderabadi biryani, Irani chai, and centuries-old culinary stories.',
        imageUrl: 'https://media-assets.swiggy.com/swiggy/image/upload/f_auto,q_auto,fl_lossy/dmgiharkcxez26ll9ma9',
        location: 'Hyderabad, Telangana, India',
        latitude: 17.3850,
        longitude: 78.4867,
        category: 'Food',
        rating: 4.8,
        tags: ['Food', 'Culture', 'Heritage', 'Nightlife'],
        price: 75.0,
        isFavorite: _favoriteIds.contains('25'),
      ),
      Destination(
        id: '26',
        name: 'Amritsar Heritage & Langar',
        description: 'Experience the Golden Temple, community langar, and bustling bazaars celebrating Punjabi hospitality.',
        imageUrl: 'https://1.bp.blogspot.com/-6V1LxjSCU3M/XYdyJ9nLapI/AAAAAAACkBU/47YEl4qcoHg_n8bUo5EJaU6WG6vtahctwCLcBGAsYHQ/s1600/DSC00113-002.jpg',
        location: 'Amritsar, Punjab, India',
        latitude: 31.6200,
        longitude: 74.8765,
        category: 'Culture',
        rating: 4.9,
        tags: ['Food', 'Spiritual', 'Culture', 'Heritage'],
        price: 55.0,
        isFavorite: _favoriteIds.contains('26'),
      ),
      Destination(
        id: '27',
        name: 'Kolkata Street Food Safari',
        description: 'Taste kathi rolls, puchkas, and colonial-era confectionery while exploring art deco neighborhoods.',
        imageUrl: 'https://images.unsplash.com/photo-1504754524776-8f4f37790ca0',
        location: 'Kolkata, West Bengal, India',
        latitude: 22.5726,
        longitude: 88.3639,
        category: 'Food',
        rating: 4.6,
        tags: ['Food', 'Street Food', 'Culture', 'Heritage'],
        price: 62.0,
        isFavorite: _favoriteIds.contains('27'),
      ),
      Destination(
        id: '28',
        name: 'Khajuraho Temples',
        description: 'UNESCO-listed temple complex renowned for its intricate sculptures and Chandela-era artistry.',
        imageUrl: 'https://s7ap1.scene7.com/is/image/incredibleindia/javari-temple-khajuraho-madhya-pradesh-2-attr-hero?qlt=82&ts=1727355489895',
        location: 'Khajuraho, Madhya Pradesh, India',
        latitude: 24.8520,
        longitude: 79.9199,
        category: 'Culture',
        rating: 4.7,
        tags: ['Culture', 'Heritage', 'Architecture', 'History'],
        price: 95.0,
        isFavorite: _favoriteIds.contains('28'),
      )
    ];
  }

  Future<List<Destination>> getDestinations({String? category, String? searchQuery}) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    List<Destination> destinations = getMockDestinations();
    
    if (category != null && category.isNotEmpty) {
      destinations = destinations.where((d) => d.category.toLowerCase() == category.toLowerCase()).toList();
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      destinations = destinations.where((d) => 
        d.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        d.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
        d.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()))
      ).toList();
    }
    
    return destinations;
  }

  Future<Destination?> getDestinationById(String id) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
    
    final destinations = getMockDestinations();
    try {
      return destinations.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Destination>> getFavoriteDestinations() async {
    final destinations = getMockDestinations();
    return destinations.where((d) => _favoriteIds.contains(d.id)).toList();
  }

  Future<bool> toggleFavorite(String destinationId) async {
    try {
      if (_favoriteIds.contains(destinationId)) {
        _favoriteIds.remove(destinationId);
      } else {
        _favoriteIds.add(destinationId);
      }
      
      await _saveFavorites();
      return true;
    } catch (e) {
      return false;
    }
  }

  bool isFavorite(String destinationId) {
    return _favoriteIds.contains(destinationId);
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favoritesKey, jsonEncode(_favoriteIds));
  }

  List<String> getCategories() {
    return [
      'City',
      'Beach',
      'Island',
      'Mountain',
      'Desert',
      'Forest',
      'Culture',
      'Food',
    ];
  }

  Future<List<Destination>> getPopularDestinations() async {
    final destinations = await getDestinations();
    destinations.sort((a, b) => b.rating.compareTo(a.rating));
    return destinations.take(5).toList();
  }

  Future<List<Destination>> getRecommendedDestinations() async {
    // In a real app, this would be based on user preferences and behavior
    final destinations = await getDestinations();
    destinations.shuffle();
    return destinations.take(4).toList();
  }
}