import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products_provider.dart';

import '../widgets/error_message.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key}) : super(key: key);
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: null, title: '', description: '', price: 0, imageUrl: '');
  final urlPicturePattern = r'(https?:\/\/.*\.(?:png|jpg))';
  var _isInitial = true;
  var _isLoading = false;
  var _initialProductValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    //сюда пихаем логику с BuildContext context
    if (_isInitial) {
      final String? productId =
          ModalRoute.of(context)!.settings.arguments as String?;
      // String*?* потому что новый продукт будет без id, следовательно значение тут будет NULL.
      if (productId != null) {
        _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findById(productId);
        _initialProductValues = {
          'title': _editedProduct.title,
          'price': _editedProduct.price.toString(),
          'description': _editedProduct.description,
          // 'imageUrl': _editedProduct.imageUrl,
          'imageUrl': '',
          //'imageUrl': '' потому что должно быть в руках контролера ввода ссылки на картинку
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInitial = false;
    super.didChangeDependencies();
  }

  // Не забудь задиспоузить лисенеры, фокус ноуды и контролеры после изпользования!
  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (!RegExp(urlPicturePattern, caseSensitive: false)
          .hasMatch(_imageUrlController.text)) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() => _isLoading = true);
    if (_editedProduct.id != null) {
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .updateExistingProduct(_editedProduct.id!, _editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => ErrorMessage(error: error),
        );
      }
    } else {
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => ErrorMessage(error: error),
        );
        // finally - тут выполняется код вне зависимости,
        // словили ли мы ошибку или нет
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактор продуктов'),
        actions: [
          IconButton(
            onPressed: () => _saveForm(),
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _form,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            initialValue: _initialProductValues['title'],
                            decoration: const InputDecoration(
                                labelText: 'Введите название продукта'),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (value) =>
                                // ета штука при завершении ввода перебрасывает на след. поле
                                FocusScope.of(context)
                                    .requestFocus(_priceFocusNode),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Название не ввел таки';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                title: newValue!,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: _editedProduct.imageUrl,
                              );
                            }),
                        TextFormField(
                            initialValue: _initialProductValues['price'],
                            decoration: const InputDecoration(
                                labelText: 'Сколько стоит?'),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            focusNode: _priceFocusNode,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'А кто цену указывать то будет? Мда';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Цена это не буквы. А цифры.';
                              }
                              if (double.parse(value) <= 0) {
                                return 'На такой "цене" не заработаешь.';
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) => FocusScope.of(context)
                                .requestFocus(_descriptionFocusNode),
                            onSaved: (newValue) {
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: double.parse(newValue!),
                                imageUrl: _editedProduct.imageUrl,
                              );
                            }),
                        TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            initialValue: _initialProductValues['description'],
                            decoration: const InputDecoration(
                                labelText: 'Введите описание'),
                            maxLines: 3,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Продукт без описания никому не будет интересен';
                              }
                              if (value.length <= 10) {
                                return 'Слишком скучное описание. Ты можешь больше!';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.multiline,
                            focusNode: _descriptionFocusNode,
                            onSaved: (newValue) {
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                title: _editedProduct.title,
                                description: newValue!,
                                price: _editedProduct.price,
                                imageUrl: _editedProduct.imageUrl,
                              );
                            }),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(top: 8, right: 10),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey),
                              ),
                              child: _imageUrlController.text.isEmpty
                                  ? const Text('Введите ссылку')
                                  : FittedBox(
                                      fit: BoxFit.contain,
                                      child: Image.network(
                                          _imageUrlController.text),
                                    ),
                            ),
                            Expanded(
                              child: TextFormField(
                                  // initialValue: _initialProductValues['imageUrl'], - редактирование отдается в руки контролеру
                                  decoration: const InputDecoration(
                                      labelText: 'Ссылка на картинку'),
                                  keyboardType: TextInputType.url,
                                  textInputAction: TextInputAction.done,
                                  controller: _imageUrlController,
                                  focusNode: _imageUrlFocusNode,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Где картинки, скучно';
                                    }
                                    if (!value.startsWith('http')) {
                                      return 'Кого ты обмануть решил?';
                                    }
                                    if (!value.endsWith('.png') &&
                                        !value.endsWith('.jpg') &&
                                        !value.endsWith('jpeg')) {
                                      return 'Это вообще не картинка.';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _saveForm(),
                                  onEditingComplete: () => setState(() {}),
                                  onSaved: (newValue) {
                                    _editedProduct = Product(
                                      id: _editedProduct.id,
                                      isFavorite: _editedProduct.isFavorite,
                                      title: _editedProduct.title,
                                      description: _editedProduct.description,
                                      price: _editedProduct.price,
                                      imageUrl: newValue!,
                                    );
                                  }),
                            ),
                          ],
                        )
                      ],
                    ),
                  )),
            ),
    );
  }
}
