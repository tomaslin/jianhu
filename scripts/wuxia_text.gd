extends RefCounted

# English remains the interface language; these are original, short in-world
# names and comic exclamations, with a separate script choice for the player.
const WORLDS = [
    ["龍門客棧", "龙门客栈"], ["少林鐘聲", "少林钟声"],
    ["梨園群俠", "梨园群侠"], ["九橋鬼市", "九桥鬼市"],
    ["竹林劍影", "竹林剑影"], ["五毒迷澤", "五毒迷泽"],
    ["赤沙商路", "赤沙商路"], ["天庭算盤", "天庭算盘"]
]
const NAMES = {
    "inn":["龍門客棧","龙门客栈"], "tea":["老酒罈","老酒坛"],
    "merchant":["米行掌櫃","米行掌柜"], "drunken":["醉拳大俠","醉拳大侠"],
    "broker":["當鋪老闆","当铺老板"], "caravan":["商隊大門","商队大门"],
    "rice":["碾米坊","碾米坊"], "gong":["銅鑼","铜锣"],
    "pond":["鯉魚池","鲤鱼池"], "fan":["鐵扇俠","铁扇侠"],
    "bandit":["攔路山賊","拦路山贼"], "physician":["遊方郎中","游方郎中"],
    "bell":["少林鐘","少林钟"], "monk":["少林和尚","少林和尚"],
    "wheel":["武當輪","武当轮"], "mirror":["明月鏡","明月镜"],
    "cloud":["雲梯","云梯"], "lantern":["紅燈籠","红灯笼"],
    "opera":["戲樓","戏楼"], "mask":["畫臉師傅","画脸师傅"],
    "assassin":["奪命面具","夺命面具"], "official":["糊塗縣令","糊涂县令"],
    "ghost":["鬼市","鬼市"], "moon":["月門","月门"],
    "boat":["紙船","纸船"], "bamboo":["竹林劍客","竹林剑客"],
    "sword":["藏劍閣","藏剑阁"], "poison":["五毒高手","五毒高手"],
    "abacus":["天庭算盤","天庭算盘"], "noodle":["麵攤","面摊"],
    "dice":["骰子館","骰子馆"], "umbrella":["傘劍女俠","伞剑女侠"],
    "lion":["舞獅班","舞狮班"], "bridge":["造橋匠","造桥匠"],
    "sleeve":["飛袖俠","飞袖侠"], "archer":["屋頂神箭","屋顶神箭"],
    "manual":["秘笈販子","秘籍贩子"], "judge":["蒙面捕快","蒙面捕快"],
    "abbot":["九杖方丈","九杖方丈"], "dummy":["木人堂","木人堂"],
    "drum":["戰鼓隊","战鼓队"], "costume":["戲服坊","戏服坊"],
    "trap":["舞台機關","舞台机关"], "ferry":["老船夫","老船夫"],
    "relic":["玉器商","玉器商"], "gourd":["藥葫蘆","药葫芦"],
    "firework":["爆竹巷","爆竹巷"], "silk":["絲路貨棧","丝路货栈"]
}
const SHOUTS = [
    ["客棧開打！","客栈开打！"], ["和尚敲鐘！","和尚敲钟！"],
    ["好戲開場！","好戏开场！"], ["鬼來啦！","鬼来啦！"],
    ["竹林過招！","竹林过招！"], ["有毒有毒！","有毒有毒！"],
    ["大漠風雲！","大漠风云！"], ["天庭亂啦！","天庭乱啦！"]
]

static func world(index:int,simplified:bool) -> String:
    return WORLDS[clampi(index,0,WORLDS.size()-1)][1 if simplified else 0]

static func actor(id:String,simplified:bool) -> String:
    var names:Array=NAMES.get(id,["江湖奇人","江湖奇人"])
    return str(names[1 if simplified else 0])

static func shout(index:int,simplified:bool) -> String:
    return SHOUTS[clampi(index,0,SHOUTS.size()-1)][1 if simplified else 0]
