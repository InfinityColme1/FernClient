import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';

final appName = "Fern";
final appLogo = 'assets/images/Fern_logo.png';

// Route
final mediaRoute = '/media';
final importRoute = '/import';
final favoritesRoute = '/favorites';
final deletedRoute = '/deleted';

final viewerRoute = '/viewer';


// Icons
final ic_right = 'assets/icons/ic_right.png';
final ic_left = 'assets/icons/ic_left.png';

final ic_info = 'assets/icons/ic_info.png';
final ic_share = 'assets/icons/ic_share.png';
final ic_delete = 'assets/icons/ic_delete.png';
final ic_heart = 'assets/icons/ic_heart.png';

// Unknown creator
final unknownCreator = CreatorEntity(
    id: 0,
    name: "Unknown"
);

// Unknown tag
final unknownTag = TagEntity(
    id: 0,
    name: "Unknown",
    children: []
);
