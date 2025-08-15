import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/trade.dart';
import '../services/database_service.dart';
import '../services/image_service.dart';
import '../widgets/custom_input_field.dart';
import '../utils/constants.dart';

class AddTradeScreen extends StatefulWidget {
  final Trade? trade; // For editing existing trades

  const AddTradeScreen({super.key, this.trade});

  @override
  State<AddTradeScreen> createState() => _AddTradeScreenState();
}

class _AddTradeScreenState extends State<AddTradeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cryptoAssetController = TextEditingController();
  final _amountController = TextEditingController();
  final _entryPriceController = TextEditingController();
  final _exitPriceController = TextEditingController();
  final _rationaleController = TextEditingController();
  
  String _selectedTradeType = 'Buy';
  String _selectedCurrency = 'USD';
  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.trade != null) {
      _isEditMode = true;
      _populateFields();
    }
  }

  void _populateFields() {
    final trade = widget.trade!;
    _cryptoAssetController.text = trade.cryptoAsset;
    _amountController.text = trade.amount.toString();
    _entryPriceController.text = trade.entryPrice.toString();
    _exitPriceController.text = trade.exitPrice?.toString() ?? '';
    _rationaleController.text = trade.rationale ?? '';
    _selectedTradeType = trade.tradeType;
    _selectedCurrency = trade.currency;
    _selectedDate = trade.date;
    if (trade.imagePath != null) {
      _selectedImage = File(trade.imagePath!);
    }
  }

  @override
  void dispose() {
    _cryptoAssetController.dispose();
    _amountController.dispose();
    _entryPriceController.dispose();
    _exitPriceController.dispose();
    _rationaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Trade' : 'Add New Trade'),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Crypto Asset
              CustomInputField(
                controller: _cryptoAssetController,
                label: 'Crypto Asset',
                hint: 'e.g., BTC, ETH, ADA',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a crypto asset';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),

              // Trade Type
              Text(
                'Trade Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Buy'),
                      value: 'Buy',
                      groupValue: _selectedTradeType,
                      onChanged: (value) {
                        setState(() {
                          _selectedTradeType = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Sell'),
                      value: 'Sell',
                      groupValue: _selectedTradeType,
                      onChanged: (value) {
                        setState(() {
                          _selectedTradeType = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Amount
              CustomInputField(
                controller: _amountController,
                label: 'Amount',
                hint: '0.00',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Entry Price
              CustomInputField(
                controller: _entryPriceController,
                label: 'Entry Price',
                hint: '0.00',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an entry price';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid positive price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Exit Price (Optional)
              CustomInputField(
                controller: _exitPriceController,
                label: 'Exit Price (Optional)',
                hint: '0.00',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Please enter a valid positive price';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Currency
              Text(
                'Currency',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: AppConstants.supportedCurrencies.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date
              Text(
                'Date',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMM dd, yyyy - HH:mm').format(_selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Rationale
              CustomInputField(
                controller: _rationaleController,
                label: 'Rationale (Optional)',
                hint: 'Why did you make this trade?',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Image Upload
              Text(
                'Trade Setup Image (Optional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                });
                              },
                              icon: const Icon(Icons.close),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    : InkWell(
                        onTap: _pickImage,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Add Trade Setup Image', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveTrade,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(_isEditMode ? 'Update Trade' : 'Save Trade'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      if (mounted) {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_selectedDate),
        );

        if (time != null) {
          setState(() {
            _selectedDate = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
          });
        } else {
          setState(() {
            _selectedDate = date;
          });
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      final savedImage = await ImageService.saveImage(image);
      setState(() {
        _selectedImage = File(savedImage);
      });
    }
  }

  Future<void> _saveTrade() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final trade = Trade(
        id: _isEditMode ? widget.trade!.id : null,
        cryptoAsset: _cryptoAssetController.text.trim().toUpperCase(),
        tradeType: _selectedTradeType,
        amount: double.parse(_amountController.text),
        entryPrice: double.parse(_entryPriceController.text),
        exitPrice: _exitPriceController.text.isNotEmpty 
            ? double.parse(_exitPriceController.text) 
            : null,
        currency: _selectedCurrency,
        date: _selectedDate,
        rationale: _rationaleController.text.trim().isNotEmpty 
            ? _rationaleController.text.trim() 
            : null,
        imagePath: _selectedImage?.path,
      );

      if (_isEditMode) {
        await DatabaseService().updateTrade(trade);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trade updated successfully!')),
          );
        }
      } else {
        await DatabaseService().insertTrade(trade);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trade saved successfully!')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving trade: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trade'),
        content: const Text('Are you sure you want to delete this trade? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteTrade();
    }
  }

  Future<void> _deleteTrade() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseService().deleteTrade(widget.trade!.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trade deleted successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting trade: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}