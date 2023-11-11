import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Footer extends ConsumerWidget {
  const Footer({super.key});

  @override
  Widget build(context, ref) {
    return Container(
      padding: const EdgeInsets.all(30),
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _help(),
                    _social(),
                    const VerticalDivider(),
                    _address(),
                  ],
                ),
              );
            } else {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _help(),
                      _social(),
                    ],
                  ),
                  const Divider(),
                  _address(),
                ],
              );
            }
          }),
          const Divider(),
          const SizedBox(height: 20),
          const Text(
            'Copyright © 2023 SUSIPERO.com',
          ),
        ],
      ),
    );
  }

  Widget _help() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: [
          Text(
            "HELP",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "寄付",
          ),
        ],
      ),
    );
  }

  Widget _social() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: [
          Text(
            "SOCIAL",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "ツイッター  ",
          ),
        ],
      ),
    );
  }

  Widget _address() {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _addressItem(
            type: 'Eメール',
            text: 'onihei_99@yahoo.co.jp',
          ),
          const SizedBox(height: 5),
          _addressItem(
            type: '電話番号',
            text: '+819058029448',
          ),
          const SizedBox(height: 5),
          _addressItem(
            type: '住所',
            text: '〒2110053\n神奈川県川崎市中原区上小田中２−２４−４４',
          )
        ],
      ),
    );
  }

  Widget _addressItem({type, text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$type',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        )
      ],
    );
  }
}
