import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:social_cv_client_flutter/src/commons/values.dart';
import 'package:social_cv_client_flutter/src/localizations/cv_localization.dart';
import 'package:social_cv_client_flutter/src/utils/logger.dart';
import 'package:social_cv_client_flutter/src/widgets/sort_box_widget.dart';
import 'package:social_cv_client_flutter/src/widgets/sort_list_tile_widget.dart';

class SortDialog extends StatefulWidget {
  const SortDialog({
    Key key,
    this.title,
    @required this.sortItems,
  })  : assert(sortItems != null),
        super(key: key);

  final Widget title;
  final List<SortListItem> sortItems;

  @override
  State<StatefulWidget> createState() => _SortDialogState();
}

class _SortDialogState extends State<SortDialog> {
  @override
  Widget build(BuildContext context) {
    final _listTiles = widget.sortItems
        .map((sortItem) => SortListTile(
              key: Key(sortItem.field),
              value: sortItem.value,
              title: Text(sortItem.title),
              onChanged: (SortState value) {
                setState(() {
                  logger.info("${sortItem.field} $value");
                  sortItem.value = value;
                });
              },
            ))
        .toList();

    return AlertDialog(
      contentPadding: EdgeInsets.all(0.0),
      title: widget.title,
      content: Container(
        width: kCVSortDialogWidth,
        height: kCVSortDialogHeight,
        child: ReorderableListView(
          onReorder: _onReorder,
          children: _listTiles,
        ),
      ),
      actions: <Widget>[
        SimpleDialogOption(
          child: Text(CVLocalizations.of(context).sortDialogCancel),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        SimpleDialogOption(
          child: Text(CVLocalizations.of(context).sortDialogConfirm),
          onPressed: null,
        ),
      ],
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final SortListItem item = widget.sortItems.removeAt(oldIndex);
      widget.sortItems.insert(newIndex, item);
    });
  }
}
