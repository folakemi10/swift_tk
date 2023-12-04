//
//  Algorithms.swift
//  Image-modification-toolkit
//
//  Created by Luke Zhang on 11/15/23.
//

import Foundation
import SwiftImage
import UIKit

class ImageModificationClass{
    
    //initialize images as all black, process them from file uploads later
    var image:Image = Image<RGBA<UInt8>>(width: 1000, height: 1000, pixel: .black)
    var rawImage:Image = Image<RGBA<UInt8>>(width: 1000, height: 1000, pixel: .black)
    
    private var tempRoots: [Int] = []
    private var pixelSize: Int = 0
    private var tempA: [Int] = []
    private var safePrime: Int = 0
    private var secretCode: String = ""
    
    private var percentScrambled: Double = 0.0
    private var percentUnscrambled: Double = 0.0
    private var percentEmojified: Double = 0.0
    
    public func getPercentScrambled() -> Double {
        return percentScrambled
    }
    public func getPercentUnscrambled() -> Double {
        return percentUnscrambled
    }
    public func getPercentEmojified() -> Double {
        return percentEmojified
    }
    
    public func getSafePrime() -> Int {
        return safePrime
    }
    public func tempRootArray() -> [Int]{
        return tempRoots
    }
    public func enhancedTempRootArray() -> [Int]{
        return tempRoots + tempA
    }
    public func getSecretCode () -> String {
        return secretCode
    }
    private var safePrimeIndex: Int = 3
    private var safePrimes: [Int] = [5, 7, 11, 23, 47, 59, 83, 107, 167, 179, 227, 263, 347, 359, 383, 467, 479, 503, 563, 587, 719, 839, 863, 887, 983, 1019, 1187, 1283, 1307, 1319, 1367, 1439, 1487, 1523, 1619, 1823, 1907, 2027, 2039, 2063, 2099, 2207, 2447, 2459, 2579, 2819, 2879, 2903, 2963, 2999, 3023, 3119, 3167, 3203, 3467, 3623, 3779, 3803, 3863, 3947, 4007, 4079, 4127, 4139, 4259, 4283, 4547, 4679, 4703, 4787, 4799, 4919]
    
    var imageNames: [String] = ["handshake_1f91d", "check-mark-button_2705", "input-latin-uppercase_1f520", "atm-sign_1f3e7", "keycap-digit-six_36-fe0f-20e3", "smiling-face_263a-fe0f", "mans-shoe_1f45e", "telescope_1f52d", "flag-uruguay_1f1fa-1f1fe", "rocket_1f680", "up-right-arrow_2197-fe0f", "keycap-digit-three_33-fe0f-20e3", "dog_1f415", "coin_1fa99", "revolving-hearts_1f49e", "ok-button_1f197", "vertical-traffic-light_1f6a6", "flag-canada_1f1e8-1f1e6", "telephone_260e-fe0f", "index-pointing-at-the-viewer_1faf5", "nazar-amulet_1f9ff", "flag-united-arab-emirates_1f1e6-1f1ea", "bell_1f514", "reminder-ribbon_1f397-fe0f", "open-mailbox-with-raised-flag_1f4ec", "pushpin_1f4cc", "japanese-bargain-button_1f250", "ringed-planet_1fa90", "trophy_1f3c6", "funeral-urn_26b1-fe0f", "up-arrow_2b06-fe0f", "thread_1f9f5", "slightly-smiling-face_1f642", "flag-uzbekistan_1f1fa-1f1ff", "hotel_1f3e8", "pile-of-poo_1f4a9", "sparkling-heart_1f496", "mechanic-medium-skin-tone_1f9d1-1f3fd-200d-1f527", "woman-scientist-medium-dark-skin-tone_1f469-1f3fe-200d-1f52c", "department-store_1f3ec", "flag-kosovo_1f1fd-1f1f0", "broom_1f9f9", "eggplant_1f346", "flag-japan_1f1ef-1f1f5", "clinking-glasses_1f942", "crown_1f451", "potable-water_1f6b0", "grinning-face-with-sweat_1f605", "bouquet_1f490", "flag-brunei_1f1e7-1f1f3", "man-teacher-light-skin-tone_1f468-1f3fb-200d-1f3eb", "flag-north-macedonia_1f1f2-1f1f0", "direct-hit_1f3af", "face-with-spiral-eyes_1f635-200d-1f4ab", "construction-worker_light-skin-tone_1f477-1f3fb_1f3fb", "man-dancing_1f57a", "kaaba_1f54b", "flag-somalia_1f1f8-1f1f4", "rolling-on-the-floor-laughing_1f923", "pig-face_1f437", "scissors_2702-fe0f", "bellhop-bell_1f6ce-fe0f", "clapper-board_1f3ac", "ferris-wheel_1f3a1", "wheelchair-symbol_267f", "face-with-tears-of-joy_1f602", "joystick_1f579-fe0f", "desert-island_1f3dd-fe0f", "speaker-medium-volume_1f509", "green-heart_1f49a", "flag-cape-verde_1f1e8-1f1fb", "pouting-face_1f621", "guitar_1f3b8", "baby-symbol_1f6bc", "sleepy-face_1f62a", "snowman-without-snow_26c4", "smiling-face-with-smiling-eyes_1f60a", "scientist-medium-light-skin-tone_1f9d1-1f3fc-200d-1f52c", "sleeping-face_1f634", "clapping-hands_1f44f", "sun-behind-cloud_26c5", "duck_1f986", "flag-nepal_1f1f3-1f1f5", "ring_1f48d", "french-fries_1f35f", "heart-hands_1faf6", "last-quarter-moon-face_1f31c", "confetti-ball_1f38a", "luggage_1f9f3", "backhand-index-pointing-down_1f447", "backpack_1f392", "diamond-with-a-dot_1f4a0", "spiral-calendar_1f5d3-fe0f", "handshake-no-skin-tone-no-skin-tone_1faf1-200d-1faf2", "clinking-beer-mugs_1f37b", "popcorn_1f37f", "flag-azerbaijan_1f1e6-1f1ff", "alembic_2697-fe0f", "yarn_1f9f6", "white-large-square_2b1c", "cooking_1f373", "leaf-fluttering-in-wind_1f343", "sport-utility-vehicle_1f699", "screwdriver_1fa9b", "flag-bahamas_1f1e7-1f1f8", "large-yellow-square_1f7e8", "flag-chile_1f1e8-1f1f1", "triangular-flag_1f6a9", "flag-malawi_1f1f2-1f1fc", "flag-sierra-leone_1f1f8-1f1f1", "white-circle_26aa", "moai_1f5ff", "mirror_1fa9e", "person-lifting-weights_1f3cb-fe0f", "cold-face_1f976", "envelope-with-arrow_1f4e9", "grapes_1f347", "flag-namibia_1f1f3-1f1e6", "flag-chad_1f1f9-1f1e9", "card-file-box_1f5c3-fe0f", "flag-yemen_1f1fe-1f1ea", "star-of-david_2721-fe0f", "flag-bulgaria_1f1e7-1f1ec", "flag-dominican-republic_1f1e9-1f1f4", "brown-heart_1f90e", "man-student-light-skin-tone_1f468-1f3fb-200d-1f393", "flag-algeria_1f1e9-1f1ff", "tiger-face_1f42f", "left-luggage_1f6c5", "large-orange-square_1f7e7", "puzzle-piece_1f9e9", "dagger_1f5e1-fe0f", "place-of-worship_1f6d0", "face-with-open-eyes-and-hand-over-mouth_1fae2", "battery_1f50b", "white-heart_1f90d", "man-office-worker-light-skin-tone_1f468-1f3fb-200d-1f4bc", "american-football_1f3c8", "fish-cake-with-swirl_1f365", "man-office-worker-medium-light-skin-tone_1f468-1f3fc-200d-1f4bc", "flag-senegal_1f1f8-1f1f3", "angry-face-with-horns_1f47f", "computer-disk_1f4bd", "paintbrush_1f58c-fe0f", "flag-bermuda_1f1e7-1f1f2", "anchor_2693", "magnet_1f9f2", "mosque_1f54c", "flag-norfolk-island_1f1f3-1f1eb", "man-mechanic-medium-light-skin-tone_1f468-1f3fc-200d-1f527", "cockroach_1fab3", "badminton_1f3f8", "exploding-head_1f92f", "flag-zimbabwe_1f1ff-1f1fc", "skateboard_1f6f9", "balloon_1f388", "flag-china_1f1e8-1f1f3", "locomotive_1f682", "large-green-circle_1f7e2", "bottle-with-popping-cork_1f37e", "crying-face_1f622", "military-medal_1f396-fe0f", "woozy-face_1f974", "gem-stone_1f48e", "flag-ukraine_1f1fa-1f1e6", "basketball_1f3c0", "joker_1f0cf", "fleur-de-lis_269c-fe0f", "tanabata-tree_1f38b", "tractor_1f69c", "circus-tent_1f3aa", "school_1f3eb", "record-button_23fa-fe0f", "anxious-face-with-sweat_1f630 (1)", "hot-pepper_1f336-fe0f", "woman-student-medium-dark-skin-tone_1f469-1f3fe-200d-1f393", "man-surfing_1f3c4-200d-2642-fe0f", "sos-button_1f198", "tiger_1f405", "large-orange-circle_1f7e0", "leftwards-hand_1faf2", "flag-kenya_1f1f0-1f1ea", "bathtub_1f6c1", "flag-russia_1f1f7-1f1fa", "graduation-cap_1f393", "magnifying-glass-tilted-left_1f50d", "dog-face_1f436", "drooling-face_1f924", "flag-scotland_1f3f4-e0067-e0062-e0073-e0063-e0074-e007f", "woman-technologist-medium-light-skin-tone_1f469-1f3fc-200d-1f4bb", "play-button_25b6-fe0f", "cookie_1f36a", "roll-of-paper_1f9fb", "fork-and-knife-with-plate_1f37d-fe0f", "axe_1fa93", "baseball_26be", "identification-card_1faaa", "upside-down-face_1f643", "flag-us-outlying-islands_1f1fa-1f1f2", "pencil_270f-fe0f", "man-mechanic-medium-dark-skin-tone_1f468-1f3fe-200d-1f527", "winking-face_1f609", "flag-svalbard-jan-mayen_1f1f8-1f1ef", "cloud_2601-fe0f", "cherry-blossom_1f338", "outbox-tray_1f4e4", "black-flag_1f3f4", "person-with-crown_1fac5", "flag-jamaica_1f1ef-1f1f2", "man-getting-massage_1f486-200d-2642-fe0f", "face-screaming-in-fear_1f631", "face-savoring-food_1f60b", "couch-and-lamp_1f6cb-fe0f", "black-heart_1f5a4", "flag-sint-maarten_1f1f8-1f1fd", "black-large-square_2b1b", "television_1f4fa", "desktop-computer_1f5a5-fe0f", "cowboy-hat-face_1f920", "large-blue-square_1f7e6", "eyes_1f440", "woman-in-tuxedo-light-skin-tone_1f935-1f3fb-200d-2640-fe0f", "lollipop_1f36d", "placard_1faa7", "christmas-tree_1f384", "orange-book_1f4d9", "keycap-digit-two_32-fe0f-20e3", "three-oclock_1f552", "satellite-antenna_1f4e1", "relieved-face_1f60c", "sun-with-face_1f31e", "printer_1f5a8-fe0f", "flag-nicaragua_1f1f3-1f1ee", "face-blowing-a-kiss_1f618", "headphone_1f3a7", "flag-botswana_1f1e7-1f1fc", "speech-balloon_1f4ac", "nerd-face_1f913", "coffin_26b0-fe0f", "man-technologist-medium-dark-skin-tone_1f468-1f3fe-200d-1f4bb", "yellow-heart_1f49b", "cactus_1f335", "watermelon_1f349", "large-blue-circle_1f535", "large-brown-square_1f7eb", "microphone_1f3a4", "butterfly_1f98b", "crossed-fingers_1f91e", "flag-united-nations_1f1fa-1f1f3", "memo_1f4dd", "musical-keyboard_1f3b9", "flag-curacao_1f1e8-1f1fc", "children-crossing_1f6b8", "counterclockwise-arrows-button_1f504", "woman-in-tuxedo-medium-light-skin-tone_1f935-1f3fc-200d-2640-fe0f", "man-shrugging_1f937-200d-2642-fe0f", "expressionless-face_1f611", "sunflower_1f33b", "transgender-flag_1f3f3-fe0f-200d-26a7-fe0f", "kissing-face-with-smiling-eyes_1f619", "woman-student-medium-light-skin-tone_1f469-1f3fc-200d-1f393", "scientist-light-skin-tone_1f9d1-1f3fb-200d-1f52c", "flag-niger_1f1f3-1f1ea", "crocodile_1f40a", "laptop_1f4bb (2)", "coat_1f9e5", "tropical-fish_1f420", "flag-south-africa_1f1ff-1f1e6", "bow-and-arrow_1f3f9", "shushing-face_1f92b", "old-key_1f5dd-fe0f", "unicorn_1f984", "chart-increasing_1f4c8", "zipper-mouth-face_1f910", "top-hat_1f3a9", "high-heeled-shoe_1f460", "taxi_1f695", "ticket_1f3ab", "keycap-digit-seven_37-fe0f-20e3", "triangular-ruler_1f4d0", "top-arrow_1f51d", "flag-hong-kong-sar-china_1f1ed-1f1f0", "shamrock_2618-fe0f", "downcast-face-with-sweat_1f613", "carpentry-saw_1fa9a", "laptop_1f4bb", "mantelpiece-clock_1f570-fe0f", "baby_1f476", "page-with-curl_1f4c3", "flag-kiribati_1f1f0-1f1ee", "man-technologist-medium-light-skin-tone_1f468-1f3fc-200d-1f4bb", "flag-qatar_1f1f6-1f1e6", "loudly-crying-face_1f62d", "pistol_1f52b", "videocassette_1f4fc", "passport-control_1f6c2", "mouth_1f444", "face-vomiting_1f92e", "no-littering_1f6af", "rainbow-flag_1f3f3-fe0f-200d-1f308", "up-left-arrow_2196-fe0f", "flag-vatican-city_1f1fb-1f1e6", "grinning-face-with-smiling-eyes_1f604", "flag-finland_1f1eb-1f1ee", "backhand-index-pointing-up_1f446", "key_1f511", "large-brown-circle_1f7e4", "warning_26a0-fe0f", "pregnant-man_1fac3", "no-one-under-eighteen_1f51e", "high-voltage_26a1", "white-flag_1f3f3-fe0f", "flag-india_1f1ee-1f1f3", "woman-in-tuxedo-medium-dark-skin-tone_1f935-1f3fe-200d-2640-fe0f", "mushroom_1f344", "playground-slide_1f6dd", "flag-ecuador_1f1ea-1f1e8", "thermometer_1f321-fe0f", "basket_1f9fa", "flexed-biceps_1f4aa", "ice-skate_26f8-fe0f", "biohazard_2623-fe0f", "shrimp_1f990", "synagogue_1f54d", "red-heart_2764-fe0f", "amphora_1f3fa", "milky-way_1f30c", "toolbox_1f9f0", "sheaf-of-rice_1f33e", "face-with-thermometer_1f912", "test-tube_1f9ea", "woman-getting-massage_1f486-200d-2640-fe0f", "rabbit-face_1f430", "keycap-digit-nine_39-fe0f-20e3", "cinema_1f3a6", "left-arrow_2b05-fe0f", "flag-cayman-islands_1f1f0-1f1fe", "no-mobile-phones_1f4f5", "sunrise-over-mountains_1f304", "smiling-face-with-horns_1f608", "star_2b50", "nut-and-bolt_1f529", "name-badge_1f4db", "dolphin_1f42c", "wilted-flower_1f940", "bank_1f3e6", "palm-tree_1f334", "folded-hands_1f64f", "flag-iraq_1f1ee-1f1f6", "hamster_1f439", "face-holding-back-tears_1f979", "melting-face_1fae0", "flag-puerto-rico_1f1f5-1f1f7", "ping-pong_1f3d3", "chair_1fa91", "hot-face_1f975", "chocolate-bar_1f36b", "flag-bangladesh_1f1e7-1f1e9", "heart-with-ribbon_1f49d", "flag-israel_1f1ee-1f1f1", "prohibited_1f6ab", "non-potable-water_1f6b1", "flag-indonesia_1f1ee-1f1e9", "mobile-phone_1f4f1", "skull_1f480", "classical-building_1f3db-fe0f", "safety-vest_1f9ba", "input-latin-lowercase_1f521", "large-red-square_1f7e5", "person-rowing-boat_1f6a3", "calendar_1f4c5", "police-car-light_1f6a8", "woman-office-worker-medium-skin-tone_1f469-1f3fd-200d-1f4bc", "hugging-face_1f917", "long-drum_1fa98", "notebook_1f4d3", "large-red-circle_1f534", "money-bag_1f4b0", "trident-emblem_1f531", "ring-buoy_1f6df", "rainbow_1f308", "oncoming-automobile_1f698", "game-die_1f3b2", "face-with-steam-from-nose_1f624", "tennis_1f3be", "flag-iceland_1f1ee-1f1f8", "open-book_1f4d6", "love-you-gesture_1f91f", "flag-brazil_1f1e7-1f1f7", "locked-with-key_1f510", "downwards-button_1f53d", "palm-up-hand_1faf4", "flag-belgium_1f1e7-1f1ea", "woman-office-worker-light-skin-tone_1f469-1f3fb-200d-1f4bc", "wrench_1f527", "bed_1f6cf-fe0f", "flag-mali_1f1f2-1f1f1", "railway-car_1f683", "flag-andorra_1f1e6-1f1e9", "flag-united-kingdom_1f1ec-1f1e7", "pregnant-man_1fac3 (1)", "flag-ascension-island_1f1e6-1f1e8", "face-with-raised-eyebrow_1f928", "keyboard_2328-fe0f", "anxious-face-with-sweat_1f630", "castle_1f3f0", "hand-with-index-finger-and-thumb-crossed_1faf0", "flag-myanmar-burma_1f1f2-1f1f2", "soap_1f9fc", "flag-st-martin_1f1f2-1f1eb", "skull-and-crossbones_2620-fe0f", "running-shirt_1f3bd", "flag-peru_1f1f5-1f1ea", "dotted-line-face_1fae5", "flag-morocco_1f1f2-1f1e6", "flag-libya_1f1f1-1f1fe", "peace-symbol_262e-fe0f", "face-with-hand-over-mouth_1f92d", "necktie_1f454", "saluting-face_1fae1", "cloud-with-lightning-and-rain_26c8-fe0f", "dizzy-face_1f635", "flag-ceuta-melilla_1f1ea-1f1e6", "page-facing-up_1f4c4", "telephone-receiver_1f4de", "flag-portugal_1f1f5-1f1f9", "hot-dog_1f32d", "wrapped-gift_1f381", "down-right-arrow_2198-fe0f", "man-judge-light-skin-tone_1f468-1f3fb-200d-2696-fe0f", "woman-teacher-light-skin-tone_1f469-1f3fb-200d-1f3eb", "flag-colombia_1f1e8-1f1f4", "flag-nigeria_1f1f3-1f1ec", "stop-sign_1f6d1", "flag-tunisia_1f1f9-1f1f3", "accordion_1fa97", "flag-thailand_1f1f9-1f1ed", "lion_1f981", "razor_1fa92", "restroom_1f6bb", "flag-gibraltar_1f1ec-1f1ee", "kiss-woman-man_1f469-200d-2764-fe0f-200d-1f48b-200d-1f468", "flag-vietnam_1f1fb-1f1f3", "flag-mexico_1f1f2-1f1fd", "inbox-tray_1f4e5", "clown-face_1f921", "flag-martinique_1f1f2-1f1f6", "keycap-digit-one_31-fe0f-20e3", "spiral-notepad_1f5d2-fe0f", "flag-turks-caicos-islands_1f1f9-1f1e8", "tulip_1f337", "man-student-medium-dark-skin-tone_1f468-1f3fe-200d-1f393", "flag-guatemala_1f1ec-1f1f9", "optical-disk_1f4bf", "party-popper_1f389", "flag-sudan_1f1f8-1f1e9", "bat_1f987", "face-with-head-bandage_1f915", "baguette-bread_1f956", "full-moon-face_1f31d", "flag-sweden_1f1f8-1f1ea", "volcano_1f30b", "flag-slovenia_1f1f8-1f1ee", "microscope_1f52c", "flag-czechia_1f1e8-1f1ff", "flag-pitcairn-islands_1f1f5-1f1f3", "woman-running_1f3c3-200d-2640-fe0f", "flag-cook-islands_1f1e8-1f1f0", "sparkles_2728", "no-entry_26d4", "backhand-index-pointing-right_1f449", "beaming-face-with-smiling-eyes_1f601", "rescue-workers-helmet_26d1-fe0f", "rightwards-hand_1faf1", "octopus_1f419", "billed-cap_1f9e2", "soccer-ball_26bd", "crown_1f451 (1)", "pizza_1f355", "link_1f517", "artist-palette_1f3a8", "lotus_1fab7", "roller-coaster_1f3a2", "light-bulb_1f4a1", "woman-construction-worker-light-skin-tone_1f477-1f3fb-200d-2640-fe0f", "airplane_2708-fe0f", "orange-heart_1f9e1", "flag-bosnia-herzegovina_1f1e7-1f1e6", "flag-saudi-arabia_1f1f8-1f1e6", "partying-face_1f973", "keycap-10_1f51f", "pleading-face_1f97a", "star-struck_1f929", "flag-lebanon_1f1f1-1f1e7", "flag-switzerland_1f1e8-1f1ed", "woman-scientist-light-skin-tone_1f469-1f3fb-200d-1f52c", "umbrella-with-rain-drops_2614", "monkey-face_1f435", "hourglass-done_231b", "call-me-hand_1f919", "love-letter_1f48c", "wine-glass_1f377", "man-technologist-light-skin-tone_1f468-1f3fb-200d-1f4bb", "building-construction_1f3d7-fe0f", "mahjong-red-dragon_1f004", "person-in-tuxedo_medium-dark-skin-tone_1f935-1f3fe_1f3fe", "flag-estonia_1f1ea-1f1ea", "person-swimming_1f3ca", "koala_1f428", "kissing-face-with-closed-eyes_1f61a", "flag-malaysia_1f1f2-1f1fe", "package_1f4e6", "ambulance_1f691", "laptop_1f4bb (1)", "flag-bahrain_1f1e7-1f1ed", "fire_1f525", "flag-lithuania_1f1f1-1f1f9", "pregnant-woman_1f930", "movie-camera_1f3a5", "rice-cracker_1f358", "yin-yang_262f-fe0f", "volleyball_1f3d0", "shield_1f6e1-fe0f", "flag-south-korea_1f1f0-1f1f7", "linked-paperclips_1f587-fe0f", "maple-leaf_1f341", "waving-hand_1f44b", "flag-cyprus_1f1e8-1f1fe", "woman-student-light-skin-tone_1f469-1f3fb-200d-1f393", "down-left-arrow_2199-fe0f", "sign-of-the-horns_1f918", "balance-scale_2696-fe0f", "flag-poland_1f1f5-1f1f1", "flag-afghanistan_1f1e6-1f1eb", "green-book_1f4d7", "closed-book_1f4d5", "collision_1f4a5", "flag-honduras_1f1ed-1f1f3", "paperclip_1f4ce", "winking-face-with-tongue_1f61c", "fox_1f98a", "zany-face_1f92a", "index-pointing-up_261d-fe0f", "flag-western-sahara_1f1ea-1f1ed", "flag-ireland_1f1ee-1f1ea", "hammer_1f528", "magic-wand_1fa84", "next-track-button_23ed-fe0f", "flag-pakistan_1f1f5-1f1f0", "large-orange-diamond_1f536", "door_1f6aa", "vulcan-salute_1f596", "bear_1f43b", "pill_1f48a", "smiling-face-with-tear_1f972", "hundred-points_1f4af", "canoe_1f6f6", "chart-increasing-with-yen_1f4b9", "red-paper-lantern_1f3ee", "globe-showing-americas_1f30e", "syringe_1f489", "person-running_1f3c3", "man-judge-medium-light-skin-tone_1f468-1f3fc-200d-2696-fe0f", "sneezing-face_1f927", "flag-laos_1f1f1-1f1e6", "pause-button_23f8-fe0f", "droplet_1f4a7", "purple-heart_1f49c", "man-judge-medium-dark-skin-tone_1f468-1f3fe-200d-2696-fe0f", "woman-technologist-light-skin-tone_1f469-1f3fb-200d-1f4bb", "kick-scooter_1f6f4", "sparkler_1f387", "flag-singapore_1f1f8-1f1ec", "flag-new-zealand_1f1f3-1f1ff", "mouse-face_1f42d", "black-circle_26ab", "last-track-button_23ee-fe0f", "new-moon-face_1f31a", "flying-saucer_1f6f8", "trumpet_1f3ba", "chains_26d3-fe0f", "flag-tuvalu_1f1f9-1f1fb", "flag-monaco_1f1f2-1f1e8", "fire-engine_1f692", "evergreen-tree_1f332", "smiling-cat-with-heart-eyes_1f63b", "flag-wales_1f3f4-e0067-e0062-e0077-e006c-e0073-e007f", "admission-tickets_1f39f-fe0f", "person-in-tuxedo_medium-light-skin-tone_1f935-1f3fc_1f3fc", "crossed-swords_2694-fe0f", "chicken_1f414", "flag-slovakia_1f1f8-1f1f0", "thinking-face_1f914", "japanese-symbol-for-beginner_1f530", "candy_1f36c", "mechanic-medium-light-skin-tone_1f9d1-1f3fc-200d-1f527", "water-closet_1f6be", "heart-on-fire_2764-fe0f-200d-1f525", "flag-reunion_1f1f7-1f1ea", "rat_1f400", "woman-dancing_1f483", "flag-french-guiana_1f1ec-1f1eb", "low-battery_1faab", "panda_1f43c", "flag-congo-brazzaville_1f1e8-1f1ec", "people-with-bunny-ears_1f46f", "night-with-stars_1f303", "snail_1f40c", "flashlight_1f526", "wind-face_1f32c-fe0f", "factory_1f3ed", "high-voltage_26a1 (1)", "sewing-needle_1faa1", "smiling-face-with-hearts_1f970", "flag-united-states_1f1fa-1f1f8", "blue-book_1f4d8", "litter-in-bin-sign_1f6ae", "1st-place-medal_1f947", "cross-mark-button_274e (1)", "middle-finger_1f595", "shinto-shrine_26e9-fe0f", "motor-scooter_1f6f5", "man-student-medium-light-skin-tone_1f468-1f3fc-200d-1f393", "snowflake_2744-fe0f (1)", "lipstick_1f484", "flag-cuba_1f1e8-1f1fa", "boxing-glove_1f94a", "keycap-digit-four_34-fe0f-20e3", "large-green-square_1f7e9", "squid_1f991", "face-with-diagonal-mouth_1fae4", "no-smoking_1f6ad", "cloud-with-lightning_1f329-fe0f", "books_1f4da", "video-game_1f3ae", "flag-croatia_1f1ed-1f1f7", "frog_1f438", "clipboard_1f4cb", "flag-madagascar_1f1f2-1f1ec", "sponge_1f9fd", "flag-turkey_1f1f9-1f1f7", "ear-of-corn_1f33d", "electric-plug_1f50c", "flag-european-union_1f1ea-1f1fa", "adhesive-bandage_1fa79", "flying-disc_1f94f", "baggage-claim_1f6c4", "file-folder_1f4c1", "cross-mark-button_274e", "mending-heart_2764-fe0f-200d-1fa79", "gear_2699-fe0f", "floppy-disk_1f4be", "snowflake_2744-fe0f", "large-yellow-circle_1f7e1", "keycap-digit-eight_38-fe0f-20e3", "stop-button_23f9-fe0f", "martial-arts-uniform_1f94b", "nauseated-face_1f922", "victory-hand_270c-fe0f", "back-arrow_1f519", "x-ray_1fa7b", "down-arrow_2b07-fe0f", "star-and-crescent_262a-fe0f", "woman-scientist-medium-light-skin-tone_1f469-1f3fc-200d-1f52c", "wastebasket_1f5d1-fe0f", "hammer-and-wrench_1f6e0-fe0f", "troll_1f9cc", "water-wave_1f30a", "flag-rwanda_1f1f7-1f1fc", "sweat-droplets_1f4a6", "guide-dog_1f9ae", "large-purple-circle_1f7e3", "house_1f3e0", "face-with-monocle_1f9d0", "woman-office-worker-medium-light-skin-tone_1f469-1f3fc-200d-1f4bc", "bikini_1f459", "statue-of-liberty_1f5fd", "flag-greece_1f1ec-1f1f7", "no-bicycles_1f6b3", "new-moon-face_1f31a (1)", "neutral-face_1f610", "four-leaf-clover_1f340", "large-purple-square_1f7ea", "japanese-secret-button_3299-fe0f", "flag-france_1f1eb-1f1f7", "kissing-face_1f617", "pirate-flag_1f3f4-200d-2620-fe0f", "round-pushpin_1f4cd", "flag-liberia_1f1f1-1f1f7", "carousel-horse_1f3a0", "construction_1f6a7", "mechanic-medium-dark-skin-tone_1f9d1-1f3fe-200d-1f527", "no-pedestrians_1f6b7", "chart-decreasing_1f4c9", "blue-heart_1f499", "person-in-tuxedo_light-skin-tone_1f935-1f3fb_1f3fb", "firecracker_1f9e8", "beach-with-umbrella_1f3d6-fe0f", "flag-england_1f3f4-e0067-e0062-e0065-e006e-e0067-e007f", "flag-benin_1f1e7-1f1ef", "flag-cote-divoire_1f1e8-1f1ee", "sailboat_26f5", "flag-latvia_1f1f1-1f1fb", "crescent-moon_1f319", "man-mechanic-light-skin-tone_1f468-1f3fb-200d-1f527", "candle_1f56f-fe0f", "flag-palestinian-territories_1f1f5-1f1f8", "flag-netherlands_1f1f3-1f1f1", "flag-hungary_1f1ed-1f1fa", "plunger_1faa0", "smirking-face_1f60f", "bar-chart_1f4ca", "flag-cameroon_1f1e8-1f1f2", "briefcase_1f4bc", "flag-sao-tome-principe_1f1f8-1f1f9", "rose_1f339", "alarm-clock_23f0", "woman-technologist-medium-dark-skin-tone_1f469-1f3fe-200d-1f4bb", "automobile_1f697", "flag-jordan_1f1ef-1f1f4", "barber-pole_1f488", "motorway_1f6e3-fe0f", "flag-norway_1f1f3-1f1f4", "smiling-face-with-halo_1f607", "flag-kuwait_1f1f0-1f1fc", "umbrella_2602-fe0f", "flag-philippines_1f1f5-1f1ed", "person-biking_1f6b4", "camping_1f3d5-fe0f", "keycap-digit-zero_30-fe0f-20e3", "crystal-ball_1f52e", "flag-costa-rica_1f1e8-1f1f7", "recycling-symbol_267b-fe0f", "rice-ball_1f359", "backhand-index-pointing-left_1f448", "play-or-pause-button_23ef-fe0f", "police-car_1f693", "globe-showing-europe-africa_1f30d", "flag-clipperton-island_1f1e8-1f1f5", "flag-germany_1f1e9-1f1ea", "bubbles_1fae7", "flag-spain_1f1ea-1f1f8", "hamburger_1f354", "hatching-chick_1f423", "man-office-worker-medium-skin-tone_1f468-1f3fd-200d-1f4bc", "shopping-cart_1f6d2", "smiling-face-with-heart-eyes_1f60d", "keycap-digit-five_35-fe0f-20e3", "right-arrow_27a1-fe0f", "hot-beverage_2615", "flag-canary-islands_1f1ee-1f1e8", "flag-comoros_1f1f0-1f1f2", "kite_1fa81", "flag-australia_1f1e6-1f1fa", "flag-greenland_1f1ec-1f1f1", "scientist-medium-dark-skin-tone_1f9d1-1f3fe-200d-1f52c", "lotion-bottle_1f9f4", "ferry_26f4-fe0f", "doughnut_1f369", "flag-uganda_1f1fa-1f1ec", "flag-luxembourg_1f1f1-1f1fa", "hospital_1f3e5", "hourglass-not-done_23f3", "newspaper_1f4f0", "face-with-peeking-eye_1fae3", "crossed-flags_1f38c", "flag-gabon_1f1ec-1f1e6", "flag-venezuela_1f1fb-1f1ea"]
    
    var imageNames2: [String] = ["002", "016", "017", "003", "149", "029", "015", "001", "014", "028", "148", "010", "004", "038", "039", "005", "011", "007", "013", "012", "006", "129", "115", "101", "049", "061", "075", "074", "060", "048", "100", "114", "128", "102", "116", "076", "062", "089", "088", "063", "077", "117", "103", "107", "113", "073", "067", "098", "099", "066", "072", "112", "106", "110", "104", "138", "064", "070", "058", "059", "071", "065", "139", "105", "111", "108", "134", "120", "068", "040", "054", "083", "097", "096", "082", "055", "041", "069", "121", "135", "109", "123", "137", "057", "043", "094", "080", "081", "095", "042", "056", "136", "122", "126", "132", "052", "046", "091", "085", "084", "090", "047", "053", "133", "127", "131", "125", "119", "045", "051", "079", "086", "092", "093", "087", "078", "050", "044", "118", "124", "130", "143", "023", "037", "036", "022", "142", "140", "008", "034", "020", "021", "035", "009", "141", "145", "151", "031", "025", "019", "018", "024", "030", "150", "144", "146", "026", "032", "033", "027", "147"]
    
    var imageNames3: [String] = ["Screenshot 2023-11-30 at 7.52.51 PM", "Screenshot 2023-11-30 at 7.55.55 PM", "Screenshot 2023-11-30 at 7.56.15 PM", "Screenshot 2023-11-30 at 7.53.49 PM", "Screenshot 2023-11-30 at 7.54.18 PM", "Screenshot 2023-11-30 at 7.57.11 PM", ".DS_S", "Screenshot 2023-11-30 at 7.57.44 PM", "Screenshot 2023-11-30 at 7.56.42 PM", "Screenshot 2023-11-30 at 7.55.45 PM", "Screenshot 2023-11-30 at 7.56.09 PM", "Screenshot 2023-11-30 at 7.55.34 PM", "Screenshot 2023-11-30 at 7.56.01 PM", "Screenshot 2023-11-30 at 7.52.57 PM", "Screenshot 2023-11-30 at 7.55.30 PM", "Screenshot 2023-11-30 at 7.52.45 PM", "Screenshot 2023-11-30 at 7.55.51 PM", "Screenshot 2023-11-30 at 7.56.27 PM", "Screenshot 2023-11-30 at 7.54.02 PM", "Screenshot 2023-11-30 at 7.58.04 PM", "Screenshot 2023-11-30 at 7.54.49 PM", "Screenshot 2023-11-30 at 7.53.41 PM", "Screenshot 2023-11-30 at 7.54.15 PM", "Screenshot 2023-11-30 at 7.54.40 PM", "Screenshot 2023-11-30 at 7.54.31 PM", "Screenshot 2023-11-30 at 7.53.56 PM", "Screenshot 2023-11-30 at 7.56.30 PM", "Screenshot 2023-11-30 at 7.55.39 PM", "Screenshot 2023-11-30 at 7.52.31 PM", "Screenshot 2023-11-30 at 7.56.51 PM", "Screenshot 2023-11-30 at 7.53.37 PM", "Screenshot 2023-11-30 at 7.53.58 PM", "Screenshot 2023-11-30 at 7.53.46 PM", "Screenshot 2023-11-30 at 7.54.21 PM", "Screenshot 2023-11-30 at 7.55.15 PM", "Screenshot 2023-11-30 at 7.56.59 PM", "Screenshot 2023-11-30 at 7.56.24 PM", "Screenshot 2023-11-30 at 7.56.47 PM", "Screenshot 2023-11-30 at 7.56.55 PM", "Screenshot 2023-11-30 at 7.52.48 PM", "Screenshot 2023-11-30 at 7.56.12 PM", "Screenshot 2023-11-30 at 7.52.39 PM", "Screenshot 2023-11-30 at 7.57.14 PM", "Screenshot 2023-11-30 at 7.54.54 PM", "Screenshot 2023-11-30 at 7.54.37 PM", "Screenshot 2023-11-30 at 7.57.04 PM", "Screenshot 2023-11-30 at 7.53.52 PM", "Screenshot 2023-11-30 at 7.54.11 PM", "Screenshot 2023-11-30 at 7.55.09 PM", "Screenshot 2023-11-30 at 7.52.25 PM", "Screenshot 2023-11-30 at 7.55.21 PM", "Screenshot 2023-11-30 at 7.52.54 PM", "Screenshot 2023-11-30 at 7.52.29 PM"]
    
    var imageNames4: [String] = ["Screenshot 2023-11-30 at 8.01.55 PM", "Screenshot 2023-11-30 at 8.02.40 PM", "Screenshot 2023-11-30 at 8.03.25 PM", "Screenshot 2023-11-30 at 8.03.13 PM", ".DS_S", "Screenshot 2023-11-30 at 8.03.03 PM", "Screenshot 2023-11-30 at 8.03.31 PM", "Screenshot 2023-11-30 at 8.03.52 PM", "Screenshot 2023-11-30 at 8.02.01 PM", "Screenshot 2023-11-30 at 8.02.13 PM", "Screenshot 2023-11-30 at 8.02.44 PM", "Screenshot 2023-11-30 at 8.01.32 PM", "Screenshot 2023-11-30 at 8.01.51 PM", "Screenshot 2023-11-30 at 8.03.09 PM", "Screenshot 2023-11-30 at 8.03.42 PM", "Screenshot 2023-11-30 at 8.04.16 PM", "Screenshot 2023-11-30 at 8.04.43 PM", "Screenshot 2023-11-30 at 8.01.29 PM", "Screenshot 2023-11-30 at 8.01.58 PM", "Screenshot 2023-11-30 at 8.02.20 PM", "Screenshot 2023-11-30 at 8.02.16 PM", "Screenshot 2023-11-30 at 8.01.27 PM", "Screenshot 2023-11-30 at 8.05.12 PM", "Screenshot 2023-11-30 at 8.04.30 PM", "Screenshot 2023-11-30 at 8.05.08 PM", "Screenshot 2023-11-30 at 8.02.59 PM", "Screenshot 2023-11-30 at 8.02.24 PM", "Screenshot 2023-11-30 at 8.02.28 PM", "Screenshot 2023-11-30 at 8.03.22 PM", "Screenshot 2023-11-30 at 8.03.18 PM", "Screenshot 2023-11-30 at 8.03.06 PM", "Screenshot 2023-11-30 at 8.04.55 PM", "Screenshot 2023-11-30 at 8.04.28 PM", "Screenshot 2023-11-30 at 8.04.00 PM", "Screenshot 2023-11-30 at 8.02.10 PM", "Screenshot 2023-11-30 at 8.02.57 PM"]
    
    public func setSafePrimeIndex (spIndex: Int) {
        safePrime = safePrimes[spIndex]
        safePrimeIndex = spIndex
    }
    public func setMosaicPixelSize (pxSize: Int) {
        pixelSize = pxSize
    }
    
    private var approxImages: [Image<RGBA<UInt8>>] = []
    
    public func setApproxImages (directoryName: String, size: Int) throws {
        for file in try Folder(path: directoryName).files {
            guard let image = Image<RGBA<UInt8>>(named: file.name)
            else {return}
            let newImage = image.resizedTo(width:size, height: size)
            approxImages.append(newImage)
        }
    }
    
    public func setApproxImages (bankIndex: Int) {
        
        //originally we were going add every image into the approxImages array, but the algorithm went way too slow
        
        //hence, we're taking a sample of 5% of the images
        
        //TODO: add images to banks 2, 3, and 4
        if (bankIndex == 1) {
            var filterIndex: Int = 0
            for imageName in imageNames {
                if let img = UIImage(named: imageName) {
                    if (filterIndex % 7 == 0) {
                        approxImages.append(Image<RGBA<UInt8>>(uiImage: img))
                    }
                }
                filterIndex += 1
            }
        }
        else if (bankIndex == 2) {
            var filterIndex: Int = 0
            for imageName in imageNames2 {
                if let img = UIImage(named: imageName) {
                    if (filterIndex % 2 == 0) {
                        approxImages.append(Image<RGBA<UInt8>>(uiImage: img))
                    }
                }
                filterIndex += 1
            }
        }
        else if (bankIndex == 3) {
            var filterIndex: Int = 0
            for imageName in imageNames3 {
                if let img = UIImage(named: imageName) {
                    approxImages.append(Image<RGBA<UInt8>>(uiImage: img))
                }
                filterIndex += 1
            }
        }
        else if (bankIndex == 4) {
            var filterIndex: Int = 0
            for imageName in imageNames4 {
                if let img = UIImage(named: imageName) {
                    if (filterIndex % 7 == 0) {
                        approxImages.append(Image<RGBA<UInt8>>(uiImage: img))
                    }
                }
                filterIndex += 1
            }
        }
    }
    
    // SPECIAL METHOD: process raw image from UIImage
    public func processRawImageFromUIImg (img: UIImage) {
        rawImage = Image<RGBA<UInt8>>(uiImage: img)
    }
       
    public func getApproxImages() -> [Image<RGBA<UInt8>>] {
        return approxImages
    }
   
    private func computeAverage (image:Image<RGBA<UInt8>>) -> RGBA<UInt8> {
        var rSum: Int = 0, gSum: Int = 0, bSum: Int = 0
        for i in image.xRange {
            for j in image.yRange {
                let pixel: RGBA<UInt8> = image[i, j]
                rSum += Int(pixel.red)
                gSum += Int(pixel.green)
                bSum += Int(pixel.blue)
            }
        }
        let totalPixels = image.width * image.height
        let rAvg = UInt8(rSum / totalPixels)
        let gAvg = UInt8(gSum / totalPixels)
        let bAvg = UInt8(bSum / totalPixels)
        return RGBA(red: rAvg, green: gAvg, blue: bAvg)
    }
    private func computeAverages (input:[Image<RGBA<UInt8>>]) -> [RGBA<UInt8>] {
        var result: [RGBA<UInt8>] = []
        for i in input {
            result.append(computeAverage(image:i))
        }
        return result
    }
    private func determineClosestIndex (input: RGBA<UInt8>) -> Int {
        var minDistance:Double = 99999999
        var minDistanceIndex:Int = 0
        let colorBank:[RGBA<UInt8>] = computeAverages(input: approxImages)
        let red:Double = Double(input.red)
        let green:Double = Double(input.green)
        let blue:Double = Double(input.blue)
        for i in 0..<colorBank.count{
            let candidate = colorBank[i]
            let candidateRed:Double = Double(candidate.red)
            let candidateGreen:Double = Double(candidate.green)
            let candidateBlue:Double = Double(candidate.blue)
            let squared:Double = pow(candidateRed - red, 2)
                               + pow(candidateGreen - green, 2)
                               + pow(candidateBlue - blue, 2)
            let distance:Double = sqrt(squared)
            if distance < minDistance {
                minDistance = distance
                minDistanceIndex = i
            }
        }
        return minDistanceIndex
    }
    public func emojify (width: Int, height: Int, emojiSize: Int)  {
        image = rawImage.resizedTo(width: width*emojiSize, height: height*emojiSize)
        for x in 0 ..< width {
            for y in 0 ..< height {
                let slice: ImageSlice<RGBA<UInt8>> = image[x * emojiSize ..< x * emojiSize + emojiSize, y * emojiSize ..< y * emojiSize + emojiSize]
                let sub:Image<RGBA<UInt8>> = Image<RGBA<UInt8>>(slice)
                let inputColor:RGBA<UInt8> = computeAverage(image: sub)
                let index:Int = determineClosestIndex(input: inputColor)
                let replace:Image<RGBA<UInt8>> = approxImages[index].resizedTo(width: emojiSize, height: emojiSize)
                for i in x * emojiSize ..< (x+1) * emojiSize {
                    for j in y * emojiSize ..< (y+1) * emojiSize {
                        let newRGB:RGBA<UInt8> = replace[i % emojiSize, j % emojiSize]
                        image[i, j] = newRGB
                    }
                }
                percentEmojified += (100.0 / Double((width * height)))
                print("(\(x), \(y)) done")
            }
        }
        UIImageWriteToSavedPhotosAlbum(image.uiImage, nil, nil, nil)
    }
    
    //constructor
    init(directory: String) {
        rawImage = Image<RGBA<UInt8>>.init(contentsOfFile: directory) ?? Image<RGBA<UInt8>>(width: 1, height: 1, pixel: .black)
    }
    
    //another constructor
    init (imageArg: UIImage) {
        processRawImageFromUIImg (img: imageArg)
    }
    
    public func getCurrentImage () -> Image<RGBA<UInt8>> {
        return image
    }
    
    //now let's start building the methods from bottom up (hierarchy-wise)
    
    //these are the deepest layer (layer 1), most primitive, helper functions
    private func prToThe(base: Int, k: Int) -> Int {
        var value = 1
        for _ in 0..<k {
            value *= base
            value %= safePrime
        }
        return value
    }

    
    private func discreteLogarithm(_ a: Int, _ b: Int, _ m: Int) -> Int {
        let n = Int(Double(m).squareRoot()) + 1
        var an = 1
        for _ in 0..<n {
            an = (an * a) % m
        }
        var value = [Int](repeating: 0, count: m)
        
        var cur = an
        for i in 1...n {
            if (value[cur] == 0) {
                value[cur] = i
            }
            cur = (cur * an) % m
        }
        
        cur = b
        for i in 0...n {
            if (value[cur] > 0) {
                let ans = value[cur] * n - i
                if (ans < m) {
                    return ans
                }
            }
            cur = (cur * a) % m
        }
        return -1
    }
    
    private func discreteLogBasePrModsafePrime_ (base: Int, k: Int) -> Int {
        return discreteLogarithm(base, k, safePrime);
    }
    
    private func computeNthRootModSafePrime (n: Int, origNum: Int) -> Int {
        var result: Int = -1
        for i in 0..<safePrime {
            if (prToThe(base: i, k: n) == origNum) {
                result = i
                break
            }
        }
        return result
    }
    
    private func resizeImage (orig: Image<RGBA<UInt8>>, targetWidth: Int, targetHeight: Int) -> Image<RGBA<UInt8>> {
        return orig.resizedTo(width: targetWidth, height: targetHeight)
    }
    
    //next layer (layer 2) of helper functions
    
    private func mosaicEncrypt (original: [Image<RGBA<UInt8>>], pr: Int) -> [Image<RGBA<UInt8>>] {
        var newArr: [Image<RGBA<UInt8>>] = []
        for i in 0..<original.count {
            newArr.append(original[prToThe(base: pr, k: i) - 1])
        }
        return newArr
    }
    
    private func funnyMosaicEncrypt (original: [Image<RGBA<UInt8>>], a: Int) -> [Image<RGBA<UInt8>>] {
        var newArr: [Image<RGBA<UInt8>>] = []
        for i in 0..<original.count {
            newArr.append(original[prToThe(base: i+1, k: a) - 1])
        }
        return newArr
    }
    
    private func mosaicDecrypt (original: [Image<RGBA<UInt8>>], pr: Int) -> [Image<RGBA<UInt8>>] {
        var newArr: [Image<RGBA<UInt8>>] = []
        for i in 0..<original.count {
            newArr.append(original[discreteLogBasePrModsafePrime_(base: pr, k: i+1) % (safePrime - 1)])
        }
        return newArr
    }
    
    private func funnyMosaicDecrypt (original: [Image<RGBA<UInt8>>], a: Int) -> [Image<RGBA<UInt8>>] {
        var newArr: [Image<RGBA<UInt8>>] = []
        for i in 0..<original.count {
            newArr.append(original[computeNthRootModSafePrime(n: a, origNum: i+1) - 1])
        }
        newArr.append(original[safePrime - 2])
        return newArr
    }
    
    //next layer (layer 3) of helper functions
    
    private func mosaicScramble(original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origRow.append(m.getPixel(xCoord:j, yCoord: y))
            }
            let scrambledRow = mosaicEncrypt(original: origRow, pr: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: j, y: y, inputimg: scrambledRow[j])
            }
            percentScrambled += 100.0 / (8.0 * Double((safePrime - 1)))
        }
        scrambled = m.getMosaic()
        return scrambled
    }
    
    private func mosaicScramble2 (original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origCol.append(m.getPixel(xCoord:x, yCoord: j))
            }
            let scrambledCol = mosaicEncrypt(original: origCol, pr: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: x, y: j, inputimg: scrambledCol[j])
            }
            percentScrambled += 100.0 / (8.0 * Double((safePrime - 1)))
        }
        scrambled = m.getMosaic()
        return scrambled
    }
    
    private func mosaicScrambleD1(original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                let modifiedY = (y + prToThe(base: pr1, k: j)) % (safePrime - 1)
                origRow.append(m.getPixel(xCoord:j, yCoord: modifiedY))
            }
            let scrambledRow = mosaicEncrypt(original: origRow, pr: pr2)
            for j in 0..<(safePrime-1) {
                let modifiedY = (y + prToThe(base: pr1, k: j)) % (safePrime - 1)
                m.setPixel(x: j, y: modifiedY, inputimg: scrambledRow[j])
            }
            percentScrambled += 100.0 / (8.0 * Double((safePrime - 1)))
        }
        scrambled = m.getMosaic()
        return scrambled
    }
    
    private func mosaicScrambleD2(original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                let modifiedX = (x + prToThe(base: pr1, k: j)) % (safePrime - 1)
                origCol.append(m.getPixel(xCoord:modifiedX, yCoord: j))
            }
            let scrambledCol = mosaicEncrypt(original: origCol, pr: pr2)
            for j in 0..<(safePrime-1) {
                let modifiedX = (x + prToThe(base: pr1, k: j)) % (safePrime - 1)
                m.setPixel(x: modifiedX, y: j, inputimg: scrambledCol[j])
            }
            percentScrambled += 100.0 / (8.0 * Double((safePrime - 1)))
        }
        scrambled = m.getMosaic()
        return scrambled
    }
    
    private func mosaicUnscrambleRows (original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origCol.append(m.getPixel(xCoord:x, yCoord: j))
            }
            let unscrambledCol = mosaicDecrypt(original: origCol, pr: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: x, y: j, inputimg: unscrambledCol[j])
            }
            percentUnscrambled += 100.0 / (8.0 * Double((safePrime - 1)))
        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    private func mosaicUnscrambleCols (original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origRow.append(m.getPixel(xCoord:j, yCoord: y))
            }
            let unscrambledRow = mosaicDecrypt(original: origRow, pr: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: j, y: y, inputimg: unscrambledRow[j])
            }
            percentUnscrambled += 100.0 / (8.0 * Double((safePrime - 1)))

        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    private func mosaicUnscrambleD1 (original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                let modifiedY = (y + prToThe(base: pr1, k: j)) % (safePrime - 1)
                origRow.append(m.getPixel(xCoord:j, yCoord: modifiedY))
            }
            let unscrambledRow = mosaicDecrypt(original: origRow, pr: pr2)
            for j in 0..<(safePrime-1) {
                let modifiedY = (y + prToThe(base: pr1, k: j)) % (safePrime - 1)
                m.setPixel(x: j, y: modifiedY, inputimg: unscrambledRow[j])
            }
            percentUnscrambled += 100.0 / (8.0 * Double((safePrime - 1)))

        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    private func mosaicUnscrambleD2 (original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                let modifiedX = (x + prToThe(base: pr1, k: j)) % (safePrime - 1)
                origCol.append(m.getPixel(xCoord:modifiedX, yCoord: j))
            }
            let unscrambledCol = mosaicDecrypt(original: origCol, pr: pr2)
            for j in 0..<(safePrime-1) {
                let modifiedX = (x + prToThe(base: pr1, k: j)) % (safePrime - 1)
                m.setPixel(x: modifiedX, y: j, inputimg: unscrambledCol[j])
            }
            percentUnscrambled += 100.0 / (8.0 * Double((safePrime - 1)))

        }
        unscrambled = m.getMosaic()
        return unscrambled
    }

    private func funnyMosaicScramble(original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origRow.append(m.getPixel(xCoord:j, yCoord: y))
            }
            let scrambledRow = funnyMosaicEncrypt(original: origRow, a: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: j, y: y, inputimg: scrambledRow[j])
            }
            percentScrambled += 100.0 / (8.0 * Double((safePrime - 1)))
        }
        scrambled = m.getMosaic()
        return scrambled
    }
    
    private func funnyMosaicScramble2 (original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origCol.append(m.getPixel(xCoord:x, yCoord: j))
            }
            let scrambledCol = funnyMosaicEncrypt (original: origCol, a: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: x, y: j, inputimg: scrambledCol[j])
            }
            percentScrambled += 100.0 / (8.0 * Double((safePrime - 1)))
        }
        scrambled = m.getMosaic()
        return scrambled
    }

    private func funnyMosaicScrambleD1(original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                let modifiedY = (y + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                origRow.append(m.getPixel(xCoord:j, yCoord: modifiedY))
            }
            let scrambledRow = funnyMosaicEncrypt(original: origRow, a: pr2)
            for j in 0..<(safePrime-1) {
                let modifiedY = (y + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                m.setPixel(x: j, y: modifiedY, inputimg: scrambledRow[j])
            }
            percentScrambled += 100.0 / (8.0 * Double((safePrime - 1)))
        }
        scrambled = m.getMosaic()
        return scrambled
    }

    private func funnyMosaicScrambleD2(original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                let modifiedX = (x + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                origCol.append(m.getPixel(xCoord:modifiedX, yCoord: j))
            }
            let scrambledCol = funnyMosaicEncrypt(original: origCol, a: pr2)
            for j in 0..<(safePrime-1) {
                let modifiedX = (x + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                m.setPixel(x: modifiedX, y: j, inputimg: scrambledCol[j])
            }
            percentScrambled += 100.0 / (8.0 * Double((safePrime - 1)))
        }
        scrambled = m.getMosaic()
        return scrambled
    }

    private func funnyMosaicUnscrambleRows (original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origCol.append(m.getPixel(xCoord:x, yCoord: j))
            }
            let unscrambledCol = funnyMosaicDecrypt(original: origCol, a: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: x, y: j, inputimg: unscrambledCol[j])
            }
            percentUnscrambled += 100.0 / (8.0 * Double((safePrime - 1)))

        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    private func funnyMosaicUnscrambleCols (original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origRow.append(m.getPixel(xCoord:j, yCoord: y))
            }
            let unscrambledRow = funnyMosaicDecrypt(original: origRow, a: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: j, y: y, inputimg: unscrambledRow[j])
            }
            percentUnscrambled += 100.0 / (8.0 * Double((safePrime - 1)))

        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    private func funnyMosaicUnscrambleD1 (original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                let modifiedY = (y + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                origRow.append(m.getPixel(xCoord:j, yCoord: modifiedY))
            }
            let unscrambledRow = funnyMosaicDecrypt(original: origRow, a: pr2)
            for j in 0..<(safePrime-1) {
                let modifiedY = (y + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                m.setPixel(x: j, y: modifiedY, inputimg: unscrambledRow[j])
            }
            percentUnscrambled += 100.0 / (8.0 * Double((safePrime - 1)))

        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    private func funnyMosaicUnscrambleD2 (original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                let modifiedX = (x + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                origCol.append(m.getPixel(xCoord:modifiedX, yCoord: j))
            }
            let unscrambledCol = funnyMosaicDecrypt(original: origCol, a: pr2)
            for j in 0..<(safePrime-1) {
                let modifiedX = (x + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                m.setPixel(x: modifiedX, y: j, inputimg: unscrambledCol[j])
            }
            percentUnscrambled += 100.0 / (8.0 * Double((safePrime - 1)))

        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    
    public func enhancedMosaicEncrypt () {
        let width = (safePrime - 1) * pixelSize
        let height = (safePrime - 1) * pixelSize
        var proots: [Int] = []
        for i in 0..<(safePrime-1) {
            proots.append(i)
        }
        for i in 0..<safePrime {
            if let j = proots.firstIndex(of: ((i*i) % safePrime)) {
                proots.remove(at: j)
            }
        }
        let randomIndex1 = Int.random(in: 0..<proots.count)
        let randomIndex2 = Int.random(in: 0..<proots.count)
        let randomIndex3 = Int.random(in: 0..<proots.count)
        let randomIndex4 = Int.random(in: 0..<proots.count)
        let randomIndex5 = Int.random(in: 0..<proots.count)
        let randomIndex6 = Int.random(in: 0..<proots.count)
        let proot1 = proots[randomIndex1]
        let proot2 = proots[randomIndex2]
        let proot3 = proots[randomIndex3]
        let proot4 = proots[randomIndex4]
        let proot5 = proots[randomIndex5]
        let proot6 = proots[randomIndex6]
        var relPrimes: [Int] = []
        for i in 0..<(safePrime-1) {
            if ((i % 2 == 1) && (i != (safePrime - 1) / 2)) {
                relPrimes.append(i)
            }
        }
        let aIndex1 = Int.random(in: 0..<relPrimes.count)
        let aIndex2 = Int.random(in: 0..<relPrimes.count)
        let aIndex3 = Int.random(in: 0..<relPrimes.count)
        let aIndex4 = Int.random(in: 0..<relPrimes.count)
        let aIndex5 = Int.random(in: 0..<relPrimes.count)
        let aIndex6 = Int.random(in: 0..<relPrimes.count)
        let a1 = relPrimes[aIndex1]
        let a2 = relPrimes[aIndex2]
        let a3 = relPrimes[aIndex3]
        let a4 = relPrimes[aIndex4]
        let a5 = relPrimes[aIndex5]
        let a6 = relPrimes[aIndex6]
        tempRoots = [proot1, proot2, proot3, proot4, proot5, proot6]
        tempA = [a1, a2, a3, a4, a5, a6]
        image = resizeImage(orig: rawImage, targetWidth: width, targetHeight: height)
        let scrambledImage = mosaicScramble(original: image, pr: proot1)
        let scrambledImage2 = mosaicScramble2(original: scrambledImage, pr: proot2)
        let scrambledImage3 = mosaicScrambleD1(original: scrambledImage2, pr1: proot3, pr2: proot4)
        let scrambledImage4 = mosaicScrambleD2(original: scrambledImage3, pr1: proot5, pr2: proot6)
        let scrambledImage5 = funnyMosaicScramble(original: scrambledImage4, pr: a1)
        let scrambledImage6 = funnyMosaicScramble2 (original: scrambledImage5, pr: a2)
        let scrambledImage7 = funnyMosaicScrambleD1 (original: scrambledImage6, pr1: a3, pr2: a4)
        let scrambledImage8 = funnyMosaicScrambleD2 (original: scrambledImage7, pr1: a5, pr2: a6)
        image = scrambledImage8
        secretCode = String(proot1) + " " + String(proot2) + " " + String(proot3) + " " + String(proot4) + " " + String(proot5) + " " + String(proot6) + " " + String(a1) + " " + String(a2) + " " + String(a3) + " " + String(a4) + " " + String(a5) + " " + String(a6) + " " + String(safePrimeIndex)
        
    }
    
    public func enhancedMosaicDecrypt (pr1: Int, pr2: Int, pr3: Int, pr4: Int, pr5: Int, pr6: Int, a1: Int, a2: Int, a3: Int, a4: Int, a5: Int, a6: Int, sPrime: Int) {
        safePrime = sPrime
        let width = (safePrime - 1) * pixelSize
        let height = (safePrime - 1) * pixelSize
        image = resizeImage (orig: rawImage, targetWidth: width, targetHeight: height)
        
        let unscrambledImage1 = funnyMosaicUnscrambleD2 (original: image, pr1: a5, pr2: a6)
        let unscrambledImage2 = funnyMosaicUnscrambleD1 (original: unscrambledImage1, pr1: a3, pr2: a4)
        let unscrambledImage3 = funnyMosaicUnscrambleRows (original: unscrambledImage2, pr: a2)
        let unscrambledImage4 = funnyMosaicUnscrambleCols (original: unscrambledImage3, pr: a1)
        
        let unscrambledImage5 = mosaicUnscrambleD2 (original: unscrambledImage4, pr1: pr5, pr2: pr6)
        let unscrambledImage6 = mosaicUnscrambleD1 (original: unscrambledImage5, pr1: pr3, pr2: pr4)
        let unscrambledImage7 = mosaicUnscrambleRows (original: unscrambledImage6, pr: pr2)
        let unscrambledImage8 = mosaicUnscrambleCols (original: unscrambledImage7, pr: pr1)
        
        image = unscrambledImage8
    }
    
    public func swapPixels (x1: Int, y1: Int, x2: Int, y2: Int) {
        image = rawImage
        let m = Mosaic(spd: safePrime - 1, ps: pixelSize, inputimg: image)
        let temp: Image<RGBA<UInt8>> = m.getPixel(xCoord: x1, yCoord: y1)
        m.setPixel(x: x1, y: y1, inputimg: m.getPixel(xCoord: x2, yCoord: y2))
        m.setPixel(x: x2, y: y2, inputimg: temp)
        image = m.getMosaic()
    }
    
    public func equivalent (inputimg: Image<RGBA<UInt8>> ) -> Bool {
        var status: Bool = false
        let modifiedInputImg = inputimg.resizedTo(width: image.width, height: image.height)
        var counter: Int = 0
        for x in 0..<image.width {
            for y in 0..<image.height {
                if (modifiedInputImg[x, y] != inputimg[x, y]) {
                    counter += 1
                }
            }
        }
        if (counter <= 400) {
            status = true
        }
        
        return status
    }
}

class Mosaic {
    private var mosaicImages: [Image<RGBA<UInt8>>] = []
    private var dimension: Int = 0
    private var pixelSize: Int = 0
    //again, initialize these as black
    private var orig:Image = Image<RGBA<UInt8>>(width: 1000, height: 1000, pixel: .black)
    private var origMosaic:Image = Image<RGBA<UInt8>>(width: 1000, height: 1000, pixel: .black)
    private var mosaic:Image = Image<RGBA<UInt8>>(width: 1000, height: 1000, pixel: .black)
    
    //constructor
    init (spd: Int, ps: Int, inputimg: Image<RGBA<UInt8>>) {
        dimension = spd
        pixelSize = ps
        orig = inputimg
        fractionate()
    }
    
    private func fractionate() {
        mosaic = resizeImage(orig: orig, targetWidth: dimension*pixelSize, targetHeight: dimension*pixelSize)
        origMosaic = resizeImage(orig: orig, targetWidth: dimension*pixelSize, targetHeight: dimension*pixelSize)
        for x in 0..<dimension {
            for y in 0..<dimension {
                let subSlice: ImageSlice<RGBA<UInt8>> = origMosaic[x*pixelSize..<(x+1)*pixelSize, y*pixelSize..<(y+1)*pixelSize]
                let sub = Image<RGBA<UInt8>>(subSlice)
                mosaicImages.append(sub)
            }
        }
    }
    
    public func getMosaic() -> Image<RGBA<UInt8>> {
        return mosaic
    }
    
    public func getMosaicImages() -> [Image<RGBA<UInt8>>] {
        return mosaicImages
    }
    
    public func setPixel(x: Int, y: Int, inputimg: Image<RGBA<UInt8>>) {
        for i in x*pixelSize..<(x+1)*pixelSize {
            for j in y*pixelSize..<(y+1)*pixelSize {
                let newRGB = inputimg[i % pixelSize, j % pixelSize]
                mosaic[i, j] = newRGB
            }
        }
    }
    
    public func getPixel (xCoord: Int, yCoord: Int) -> Image<RGBA<UInt8>> {
        return mosaicImages[dimension * xCoord + yCoord]
    }

    private func resizeImage (orig: Image<RGBA<UInt8>>, targetWidth: Int, targetHeight: Int) -> Image<RGBA<UInt8>> {
        return orig.resizedTo(width: targetWidth, height: targetHeight)
    }
}
