# PixBlood Hero — 中英双语图像复刻提示词

## 来源与使用 / Source and use

本文根据同目录下的 [`hero.png`](hero.png) 画面反推编写，**不是从图片中提取的原始生成提示词**。角色、材质和场景名称属于视觉描述，不代表已确认的角色身份、装备名称或游戏地点。构图位置为目测近似值。

This document reconstructs a prompt from the visible content of [`hero.png`](hero.png) in the same directory. **It is not the original prompt extracted from the image.** Character, material, and location descriptions are visual interpretations, not confirmed character identities, equipment names, or game locations. Composition coordinates are approximate visual estimates.

中文和英文主提示词可以分别独立使用，并搭配对应的负面约束。若生成工具支持参考图，可同时提供 `hero.png`，用于约束构图与视觉细节。后面的细节拆解可用于局部修改或进一步强化要求。

Use either complete prompt independently, together with its matching negative constraints. If the generation tool accepts reference images, also supply `hero.png` to guide composition and visual details. The breakdown below supports selective revisions or stronger local constraints.

## 中文完整提示词

创作一张约 3:1 超宽横幅比例的黑暗奇幻游戏主视觉，画面铺满整个画布，无边框。整体是一幅高细节、电影海报级的写实数字插画：沉重、冷酷、压迫、肃杀，表现一名鲜血死亡骑士立于阴暗的废墟战场，身后是月光照耀的哥特式要塞。配色几乎完全由煤黑、铁灰、冷银白与血红构成；鲜红色是唯一强烈的高饱和强调色。重点是左侧的重甲骑士、横贯下方的巨型符文剑，以及中右侧清晰醒目的 “PixBlood” 金属标题。

采用略微仰视的近中景英雄构图。骑士占据左侧约四成画幅，身体从下边缘截断，头部位于横向约三分之一处并接近顶边，头盔最高的尖刺逼近或越出上边缘。身躯以四分之三角度朝向画面右侧，脸朝向观者与右前方之间，姿态稳固、强硬，不做奔跑或跳跃动作。近侧肩甲巨大，向左上方撑开轮廓，胸甲和腰带呈现厚重的层叠结构。面部完全隐藏在黑色封闭头盔内，头盔具有狭长面罩、锋利的下颌、纵向面部棱线，以及像铁王冠一样向上延伸的数根长尖刺。双眼只露出狭窄而强烈的红色光芒，形成头部最醒目的视觉焦点。

盔甲采用熏黑钢铁与磨损银色金属包边。肩甲、胸甲、护臂、手甲和腰甲由大量相互搭接的硬质金属片构成，边缘尖锐，表面布满划痕、凹坑、暗色污渍和细碎反光。近侧肩甲上有突出的骷髅浮雕与朝外伸出的尖刺，胸肩连接处有圆形骷髅徽章，腹部与腰带中央还有骷髅装饰；这些是嵌入装备的金属或骨质造型，不是悬浮物。胸腹间保留复杂但可信的铆接、接缝、锁链和层叠护板。冷银色高光勾勒硬边，暗红反光渗入盔甲下缘与缝隙。

一件厚重、破败的暗红黑色披风从肩背向画面左侧展开，形成多层折叠和破碎的长条状下摆，边缘撕裂、烧蚀般不规则，部分区域沉入近黑阴影。披风后方及周围卷起血红色能量，混有烟雾、细小火星、抽象发光符文和清晰的方形像素碎片。让这些方块像正在解体的魔法残片一样沿弧线绕过骑士，从左侧立柱附近延伸到人物右后方；保持主体为写实插画，只把像素形状用于局部魔法效果。

骑士以画面左侧可见的金属手甲紧握剑柄，手位于左侧中下部。剑柄向左延伸，带有暗红缠绕质感和棱角分明的金属尾饰。巨大双手符文剑从手部附近向右下方斜贯画面，占据整个下半部的重要位置；宽厚剑身的尖端落在画面横向约六成、靠近下边缘的位置。剑身以黑色和深红色为底，外缘是明亮、锋利、磨损的银色金属刃，护手和剑身轮廓带有倒钩、尖齿、骨刺般的装饰，显得沉重而危险。剑刃正面朝向观者，便于看清宽大的剑面和雕刻细节。

剑格附近有一个圆形的血红发光符印，沿剑身排列数个彼此分开的角形符文，像古老的魔法文字，而不是可读的现代字母。剑身内部有细密的红色熔裂纹路，鲜红光线沿裂隙与雕刻扩散。下沿悬着少量暗红滴状和丝状痕迹，周围翻涌着红色魔法焰流、烟气、细粒和碎屑。剑的银色轮廓保持锐利清晰，不被红光完全淹没。红色能量沿下方地面流动，把骑士、巨剑和前景废墟联系起来。

画面中右侧放置唯一可读的文字：“PixBlood”，严格保持这个拼写和大小写，P 与 B 大写，其余小写，单行排布，不添加副标题或说明文字。标题大致占据横向 46% 至 85% 的区域，处于画面中部偏上位置，在人物右侧展开，后面保留一块较暗的烟云背景，确保辨识度。字体是高挑、优雅而锋利的古典衬线字，带哥特奇幻气质，但不要使用难以辨读的密集黑体哥特字。字面为冷银白色的厚金属，具有斜切边缘、磨损斑点、浅划痕和克制的立体厚度；局部下缘带有深红描边或血色反光。

把标题中的大写 B 作为特别的装饰中心：一条细长、对称、像仪式长剑或尖塔的红色竖向符号与 B 的左侧竖笔画融合，上端明显高于字母，下端明显低于文字基线。该符号在上下端形成针尖与小型弯钩，中央有血红色光晕、碎屑和细小飞溅。装饰应服务于 “PixBlood” 的可读性，不能把 B 变成另一个字母，也不要插入多余字符。

右侧背景是一座极高、极窄、近乎黑色剪影的哥特式城堡。主塔位于右侧约五分之一范围内，上端逼近或越出画面顶边，周围密集分布层层退后的尖塔、扶壁和尖顶建筑。主塔上只有少量狭长的暗红发光窗缝。城堡背后靠右上方是一轮巨大的冷白色近满月，表面有明显月海和陨石坑纹理，部分被主塔与流动的乌云遮挡。月亮提供冷色轮廓光，而不是把整片天空照得明亮。

城堡下方有一座横跨峡谷的古老石桥，多个高大的桥拱在雾气中依次展开。桥下可见狭窄的水流与白灰色瀑布，从岩石断崖落入阴暗的谷底。远方是层层叠叠、边缘尖锐的黑色山体，低处被灰白雾气覆盖，形成从前景锐利到远景朦胧的空间深度。右侧城堡与石桥细节可辨，但对比度低于骑士、剑和标题。

在画面最左与最右边缘各设置一根高耸的黑色符文石柱或方尖碑，局部被画框裁切。石柱表面刻有纵向排列的鲜红几何符号，刻槽中透出猩红光，底部和边缘散逸方块状能量碎片。战场中零散竖立倾斜的旗杆，悬挂破烂的深黑红色军旗；部分旗面隐约带有骷髅图案。前景铺满尖锐黑岩、碎石、残破木料与暗色残骸，左下角岩石旁有一颗部分陷入阴影的骷髅。所有配景都保持阴暗、残破、风化的统一状态。

照明采用高反差、低调光：月光与天空的冷灰漫射光勾出头盔、肩甲、剑刃和建筑轮廓；符文、眼睛和血色能量提供局部红色发光与反射。天空遍布厚重的炭灰色风暴云，中心上方保留较深的黑色云团。红色光晕要有层次，核心明亮，向外快速衰减，不要覆盖掉金属、布料和石头纹理。视觉层级明确：先看到红眼骑士与银色标题，再看到红色符文巨剑，最后发现月亮、城堡、石桥和废墟细节。成图应具备精细的材质、清晰的轮廓、可信的体积、丰富的暗部层次和完整的横幅构图。

### 中文负面约束

不要卡通、Q 版、动漫脸、低多边形、整幅像素画、扁平矢量风格或塑料玩具质感。不要暖金色阳光、蓝色魔法、紫色霓虹、绿色火焰或彩虹色调。不要裸露脸部、裸露皮肤、额外人物、坐骑、枪械或科幻机甲。不要把剑换成斧头、细剑或光剑，不要缩小巨剑或改变其向右下方延伸的主要方向。不要额外肢体、重复手指、断裂剑身、漂浮装备或不合理的持握。不要干净崭新的盔甲、平整完好的披风或明亮舒适的城堡。不要过曝红光、大面积纯白高光、过强镜头光斑、模糊主体或无法辨认的暗部。不要误拼 “PixBlood”，不要写成 “Pix Blood” 或全部大写，不要额外标题、标语、水印、界面控件、边框或第二个标志。不要让标题遮住骑士头盔或让城堡抢占人物的视觉中心。

## Complete English prompt

Create an approximately 3:1 panoramic dark fantasy hero banner, filling the entire canvas without a border. Render it as an exceptionally detailed, realistic digital illustration with the presence of a cinematic game poster: heavy, cold, oppressive, and foreboding. A blood-themed death knight stands in a ruined battlefield, with a moonlit Gothic fortress behind him. Restrict the palette almost entirely to coal black, iron gray, cold silver-white, and blood red. Vivid red is the only strong, highly saturated accent. The primary elements are the armored knight on the left, the enormous runic sword crossing the lower portion, and the clearly legible metallic title “PixBlood” across the middle-right.

Use a slightly low camera angle and a close-to-medium heroic framing. The knight occupies roughly the left two-fifths of the composition, with his lower body cropped by the bottom edge. His head sits near one-third of the image width and close to the upper edge; the tallest helmet spikes approach or extend beyond the frame. His torso turns three-quarters toward the right, while his face points between the viewer and the right foreground. His stance is planted and forceful, without running or jumping. An oversized near shoulder plate pushes his silhouette upward and leftward; his breastplate and waist armor form a dense, heavy assembly of overlapping layers. Hide the face completely inside an enclosed black helmet with a narrow faceplate, a sharp jaw, vertical facial ridges, and several long crown-like spikes. Show only narrow, intensely glowing red eyes, the brightest focal point within the helmet.

Build the armor from blackened steel with worn silver metal edging. Layer hard overlapping plates across the shoulders, chest, forearms, gauntlets, and waist. Give every surface fine scratches, small dents, dark staining, and broken metallic reflections. The near pauldron carries a prominent sculpted skull and outward-pointing spikes. Include a round skull medallion near the shoulder-to-chest connection and additional skull ornaments at the abdomen and central belt. These ornaments are integrated into the equipment, not floating objects. Preserve intricate but plausible rivets, seams, chains, and articulated armor sections. Cold silver highlights define the hard edges, while dark crimson reflected light enters the lower edges and gaps.

A heavy, ruined cloak in black and deep burgundy spreads from the knight's back toward the left edge. Its cloth folds into overlapping masses and ragged strips, with torn, irregular, almost scorched edges; parts disappear into near-black shadow. Behind and around the cloak, curl streams of blood-red magical energy mixed with smoke, tiny sparks, abstract luminous runes, and distinct square pixel fragments. Arrange these fragments as disintegrating magical debris following curved paths from the left obelisk and around the knight's rear silhouette. Keep the overall image realistically painted; use pixel shapes only as a localized magical effect.

The visible armored hand on the left side of the image firmly grips the sword handle in the lower-left middle area. The handle extends leftward, with a dark red wrapped surface and an angular metal pommel. An enormous two-handed runeblade cuts diagonally from the grip toward the lower right, dominating the lower half of the banner. Its broad point ends around three-fifths of the image width, near the bottom edge. The blade has a black and deep crimson interior surrounded by bright, sharp, weathered silver cutting edges. Shape the guard and blade outline with hooked projections, jagged teeth, and bone-like spikes, creating a heavy, threatening weapon. Turn the broad face of the blade toward the viewer so its engraved surface remains visible.

Place a circular, glowing blood-red sigil near the guard. Along the blade, arrange several separate angular runes that resemble ancient magical writing rather than readable modern letters. Fill the dark blade with fine branching crimson cracks, allowing red light to travel through the fissures and engravings. A few dark red drops and string-like trails hang beneath its lower edge. Surround it with turbulent red magical flame, smoke, fine particles, and fragments. Preserve the crisp silver cutting edge instead of burying it in bloom. Let streams of red energy continue across the ground, visually connecting the knight, sword, and ruined foreground.

Place the only readable text, “PixBlood”, prominently across the middle-right. Use exactly this spelling and capitalization: uppercase P and B, all remaining letters lowercase, one continuous word on one line. Add no subtitle or explanatory copy. The title occupies approximately 46% to 85% of the image width, around the upper-middle of the frame, extending to the right of the knight. Reserve a relatively dark cloud field behind it for clear readability. Use tall, elegant, sharply cut classical serif lettering with a Gothic fantasy character, avoiding dense, illegible blackletter. The letter faces are cold silver-white metal, with beveled edges, worn speckling, light scratches, and restrained dimensional depth. Add thin dark crimson edging or reflected blood-red light along portions of the lower contours.

Make the capital B the title's ornamental center. Integrate a long, slender, vertically symmetrical red motif into its left upright, resembling a ritual sword or needle-like spire. Extend it clearly above the letter top and below the text baseline. Form pointed tips and small curved hooks at its upper and lower ends, with a concentrated crimson glow, fragments, and tiny spatters around the center. This ornament must preserve the readability of “PixBlood”; it must not transform the B into another letter or introduce an extra character.

In the right background, place an extremely tall, narrow Gothic fortress, almost a black silhouette. Its principal tower sits within the rightmost fifth of the composition and approaches or passes beyond the upper edge. Surround it with densely layered subordinate spires, buttresses, and pointed roofs receding into the distance. Only a few narrow dark red window slits glow within the main tower. Behind it in the upper right hangs a huge cold white, nearly full moon, with visible lunar maria and crater texture. Let the tower and moving storm clouds obscure parts of the moon. Use it as a source of cold rim light without making the whole sky bright.

Beneath the fortress, an ancient stone bridge crosses a ravine, its sequence of tall arches fading into mist. Below the bridge, narrow streams and pale gray-white waterfalls descend from rocky ledges into a dark valley. Layer jagged black mountain silhouettes behind the architecture. Low gray-white fog gathers in the valleys, creating depth from the sharp foreground to the softened distance. Keep the castle and bridge recognizable but lower in contrast than the knight, sword, and title.

At the extreme left and right edges, place tall black rune pillars or obelisks, partially cropped by the frame. Carve vertical arrangements of vivid red geometric symbols into their faces. Scarlet light shines from the grooves, with square energy fragments breaking away from their edges and bases. Scatter leaning flagpoles across the battlefield, carrying shredded black and burgundy war banners; some faintly display skull emblems. Fill the foreground with sharp black rocks, rubble, broken timber, and dark wreckage. Include a partially shadowed skull among the rocks in the lower-left corner. Keep every secondary element dark, weathered, and ruined.

Use high-contrast, low-key illumination. Cold gray moonlight and diffuse sky light trace the helmet, shoulder plates, blade edges, and architectural silhouettes. Runes, eyes, and blood-red magic create localized emission and reflected light. Fill the sky with heavy charcoal storm clouds, retaining a particularly dark cloud mass above the center. Give red glows controlled falloff: bright at the core, quickly dimming outward, preserving metal, fabric, and stone texture. Maintain a clear visual hierarchy: the red-eyed knight and silver title register first, the glowing runeblade second, and the moon, fortress, bridge, and battlefield details afterward. Deliver finely resolved materials, sharp silhouettes, convincing volume, layered shadows, and a coherent panoramic composition.

### English negative constraints

No cartoon, chibi, anime face, low-poly rendering, full-image pixel art, flat vector graphics, or plastic toy materials. No warm golden sunlight, blue magic, purple neon, green fire, or rainbow palette. No exposed face or skin, additional characters, mounts, firearms, or science-fiction mech armor. Do not replace the greatsword with an axe, rapier, or lightsaber; do not shrink it or change its dominant diagonal toward the lower right. No extra limbs, duplicated fingers, broken blade geometry, floating equipment, or implausible grip. No pristine armor, intact clean cloak, or bright welcoming castle. No excessive red bloom, broad blown-out white highlights, strong lens flare, blurred subject, or unreadable crushed shadows. Do not misspell “PixBlood”, split it into “Pix Blood”, or set it entirely in uppercase. No additional titles, slogans, watermarks, interface elements, borders, or second logo. Do not cover the helmet with the title or let the castle replace the knight as the principal subject.

## 细节拆解 / Detail breakdown

### 1. 画幅与空间 / Frame and spatial layout

- **中文：** 约 3:1 的超宽画面。左侧人物形成最大实体块面，中右侧标题形成最醒目的亮色平面，下方巨剑形成从左上向右下的主斜线。人物、标题、剑构成主要视觉关系，城堡退居背景。
- **English:** An approximately 3:1 ultrawide frame. The knight supplies the largest solid mass on the left, the title forms the prominent bright plane on the middle-right, and the sword establishes the main descending diagonal below. Knight, title, and sword define the composition; the fortress stays behind them.
- **中文：** 画面不是左右对称。左侧拥挤、厚重、近距离；右侧通过云层、月亮、山体和桥梁展开纵深。标题后方的深色区域承担视觉留白，但仍有微弱烟云纹理。
- **English:** Avoid bilateral symmetry. The left is dense, heavy, and close; the right opens into layers of clouds, moon, mountains, and bridge. The darker field behind the title supplies visual breathing room while retaining subtle cloud texture.

### 2. 角色轮廓 / Character silhouette

- **中文：** 头盔尖冠、突出的肩甲、外翻尖刺、宽厚胸膛和碎裂披风共同构成轮廓。头部相对肩宽显得较小，强调重装压迫感。眼睛发光，但整个面罩不能变成一团红色。
- **English:** Define the silhouette through the spiked crown, projecting pauldrons, outward spikes, broad chest, and shredded cloak. Keep the head comparatively small against the shoulder width to emphasize the armor's mass. The eyes glow without turning the whole faceplate red.

### 3. 材质区分 / Material separation

- **中文：** 金属呈现硬边和窄而亮的反光，布料呈现柔软折痕与吸光暗面，岩石呈现粗糙颗粒与破碎截面，烟雾呈现半透明层次。红色反射跨越这些材质，但每种材质仍有独立的质感。
- **English:** Give metal hard edges and narrow bright reflections, cloth soft folds and light-absorbing shadows, rock rough grain and fractured faces, and smoke translucent layers. Red reflected light connects these surfaces without erasing their individual material behavior.

### 4. 两类符号 / Two symbol systems

- **中文：** 剑、石柱与空中残片上的符文属于抽象几何魔法图形，不需要翻译成真实文字。标题 “PixBlood” 则必须完全可读、拼写准确；两者不可混淆。
- **English:** Runes on the blade, pillars, and airborne fragments are abstract geometric magical symbols and need not correspond to real writing. The title “PixBlood” must remain fully readable and accurately spelled. Keep these two systems distinct.

### 5. 红色能量 / Red energy

- **中文：** 同时包含细线状裂隙、带状流动、雾状辉光、火星和方块碎片。不要把所有红色效果处理成同一种火焰。像素碎片主要散布于人物周围、石柱边缘和战场低处，尺寸与密度存在变化。
- **English:** Combine hairline fissures, ribbon-like streams, diffuse glow, sparks, and square fragments. Do not render every red effect as the same kind of flame. Concentrate pixel fragments around the knight, along the pillars, and near the ground, varying their size and density.

### 6. 标题工艺 / Title treatment

- **中文：** 银色字面应看起来像磨损雕刻金属，而非纯白平面字或镜面铬字。细衬线、锐角、内侧暗边与局部红色反光共同制造立体感。B 的红色竖向装饰是标题的一部分，不是独立悬浮的第二个标志。
- **English:** Make the silver letter faces resemble weathered carved metal, not flat white type or mirror chrome. Fine serifs, sharp corners, dark inner edges, and selective red reflections create depth. The red vertical ornament belongs to the B rather than forming a separate floating logo.

### 7. 景深与天气 / Depth and weather

- **中文：** 前景岩石、人物、手甲与剑刃最清晰；城堡轮廓清楚而内部偏暗；远山、谷底和瀑布由薄雾软化。天空以大片翻卷乌云为主，不应出现晴朗蓝天或均匀无纹理黑底。
- **English:** Keep foreground rocks, the knight, gauntlet, and blade sharpest. Preserve the castle's silhouette while darkening its interior detail. Soften distant mountains, the valley, and waterfalls with mist. Use broad turbulent storm clouds rather than a clear blue sky or a featureless black backdrop.

### 8. 复刻优先级 / Reconstruction priorities

- **中文：** 优先保留超宽比例、左侧黑甲红眼骑士、下方右斜巨剑、中右侧银色 “PixBlood” 与红色 B 装饰、右上月亮和尖塔。其次还原骷髅装甲、红色符文、披风和像素碎片。最后补充桥拱、瀑布、旗帜、前景骷髅与微小表面划痕。
- **English:** First preserve the panoramic ratio, black-armored red-eyed knight on the left, greatsword descending toward the right, silver “PixBlood” title with its red B ornament, and upper-right moon and spires. Next refine skull armor, red runes, cloak, and pixel fragments. Finally resolve bridge arches, waterfalls, banners, the foreground skull, and tiny surface scratches.
