import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  // Added so the status update when change focus of the img, and the img preview loads...
  final _imageUrlFocusNode = FocusNode();
  // just to get the value before the form is submitted, to use on preview (and added set state on the submit)
  final _imageUrlController = TextEditingController();
  // Global key to interact with a widget inside the code, in this case Form
  final _form = GlobalKey<FormState>();
  var _editedProd = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );
  var _isInit = true;

  // Listening to changes on the Image Focus Node (respond with the updateImage function in case of a change is detected)
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImage);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final prodId = ModalRoute.of(context).settings.arguments as String;
      if (prodId != null) {
        _editedProd =
            Provider.of<Products>(context, listen: false).findById(prodId);
        _imageUrlController.text = _editedProd.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImage);
    _priceFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImage() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm() {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    if (_editedProd.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProd.id, _editedProd);
    } else {
      Provider.of<Products>(context, listen: false).addProduct(_editedProd);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          autovalidate: true,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _editedProd.title,
                  decoration: InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please provide title";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _editedProd = Product(
                      id: _editedProd.id,
                      title: value,
                      price: _editedProd.price,
                      imageUrl: _editedProd.imageUrl,
                      description: _editedProd.description,
                      isFavorite: _editedProd.isFavorite,
                    );
                  },
                ),
                TextFormField(
                  initialValue: _editedProd.price.toString(),
                  decoration: InputDecoration(labelText: 'Price'),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  focusNode: _priceFocusNode,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please enter a price";
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Please enter number greater than 0';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _editedProd = Product(
                      id: _editedProd.id,
                      title: _editedProd.title,
                      price: double.parse(value),
                      imageUrl: _editedProd.imageUrl,
                      description: _editedProd.description,
                      isFavorite: _editedProd.isFavorite,
                    );
                  },
                ),
                TextFormField(
                  initialValue: _editedProd.description,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a description';
                    }
                    if (value.length < 10) {
                      return 'Please provide a longer description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _editedProd = Product(
                      id: _editedProd.id,
                      title: _editedProd.title,
                      price: _editedProd.price,
                      imageUrl: _editedProd.imageUrl,
                      description: value,
                      isFavorite: _editedProd.isFavorite,
                    );
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(
                        top: 8,
                        right: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      child: _imageUrlController.text.isEmpty
                          ? Text('Enter URL')
                          : FittedBox(
                              child: Image.network(
                                _imageUrlController.text,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Image URL'),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: _imageUrlController,
                        onFieldSubmitted: (_) => _saveForm(),
                        focusNode: _imageUrlFocusNode,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter image URL';
                          }
                          if (!value.startsWith('http')) {
                            return 'Please enter a valid URL';
                          }
                          if (!value.endsWith('.png') &&
                              !value.endsWith('.jpg') &&
                              !value.endsWith('.jpeg')) {
                            return "Please enter a valid image format";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProd = Product(
                            id: _editedProd.id,
                            title: _editedProd.title,
                            price: _editedProd.price,
                            imageUrl: value,
                            description: _editedProd.description,
                            isFavorite: _editedProd.isFavorite,
                          );
                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
