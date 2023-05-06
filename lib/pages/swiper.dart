import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';


class MySwiper extends StatelessWidget {
  const MySwiper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var images = [
      Image.asset('assets/pages/1.png', fit: BoxFit.contain,),
      Image.asset('assets/pages/2.png', fit: BoxFit.contain,),
      Image.asset('assets/pages/3.png', fit: BoxFit.contain,),
      Image.asset('assets/pages/4.png', fit: BoxFit.contain,)
    ];
    return Stack(
      children:[
        Positioned.fill(
          child: SizedBox(
              child: Container(
                decoration:
                const BoxDecoration(color: Color.fromARGB(150, 58, 56, 56)),
              )
          )
      ),
        TapRegion(
          onTapOutside: (event) {
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: (MediaQuery.of(context).size.height-667 + 70)/2),
            child: Swiper(
            itemBuilder: (BuildContext context, int index) {
              return images[index];
            },
            indicatorLayout: PageIndicatorLayout.COLOR,
            pagination: const SwiperPagination(),
            control: const SwiperControl(),
            itemCount: 4,
            viewportFraction: 0.8,
            scale: 0.9,
            ),
          ),
        ),
      ]
    );
  }
}
