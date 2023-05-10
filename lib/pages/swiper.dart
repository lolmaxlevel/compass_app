import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';

const imageCount = 2;
class MySwiper extends StatelessWidget {
  const MySwiper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagesD = <Image>[];
    final imagesL = <Image>[];
    for (var i=1; i<=imageCount; i++) {
      imagesL.add(Image.asset('assets/pages/$i(l).png', fit: BoxFit.contain,));
      imagesD.add(Image.asset('assets/pages/$i(d).png', fit: BoxFit.contain,));
    }

    return Stack(
      children:[
        Positioned.fill(
          child: SizedBox(
              child: Container(
                decoration:
                const BoxDecoration(color: Color.fromARGB(220, 39, 39, 39)),
              )
          )
      ),
        TapRegion(
          onTapOutside: (event) {
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: (MediaQuery.of(context).size.height * 0.135)),
            child: Swiper(
              itemBuilder: (BuildContext context, int index) {
                // might be better without 2 lists, with
                // AdaptiveTheme.of(context).mode.isDark
                //                     ? Image.asset('assets/pages/${index+1}(d).png', fit: BoxFit.contain,)
                //                     : Image.asset('assets/pages/${index+1}(l).png', fit: BoxFit.contain,);
                return AdaptiveTheme.of(context).mode.isDark
                    ? imagesD[index]
                    : imagesL[index];
                },
              indicatorLayout: PageIndicatorLayout.COLOR,
              pagination:
              const SwiperPagination(
                margin: EdgeInsets.only(top: 0),
              ),
              itemCount: imageCount,
              viewportFraction: 0.8,
              scale: 0.9,
            ),
          ),
        ),
      ]
    );
  }
}
