import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/itinerary_provider.dart';
import '../models/itinerary.dart';
import '../utils/constants.dart';

class CreateItineraryScreen extends StatefulWidget {
  final String? itineraryId;
  
  const CreateItineraryScreen({super.key, this.itineraryId});

  @override
  State<CreateItineraryScreen> createState() => _CreateItineraryScreenState();
}

class _CreateItineraryScreenState extends State<CreateItineraryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _budgetController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  String _currency = 'USD';
  bool _isLoading = false;
  Itinerary? _existingItinerary;

  @override
  void initState() {
    super.initState();
    if (widget.itineraryId != null) {
      _loadExistingItinerary();
    }
  }

  void _loadExistingItinerary() {
    final provider = Provider.of<ItineraryProvider>(context, listen: false);
    _existingItinerary = provider.getItineraryById(widget.itineraryId!);
    
    if (_existingItinerary != null) {
      _titleController.text = _existingItinerary!.title;
      _descriptionController.text = _existingItinerary!.description;
      _imageUrlController.text = _existingItinerary!.imageUrl;
      final existingBudget = _existingItinerary!.totalBudget;
      _budgetController.text = existingBudget != 0.0 ? existingBudget.toString() : '';
      _startDate = _existingItinerary!.startDate;
      _endDate = _existingItinerary!.endDate;
      _currency = _existingItinerary!.currency;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, reset it
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start date first')),
      );
      return;
    }
    
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!,
      lastDate: _startDate!.add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _saveItinerary() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<ItineraryProvider>(context, listen: false);
    
    try {
      if (_existingItinerary != null) {
        // Update existing itinerary
        final updatedItinerary = Itinerary(
          id: _existingItinerary!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          startDate: _startDate!,
          endDate: _endDate!,
          days: _existingItinerary!.days,
          imageUrl: _imageUrlController.text.trim(),
          totalBudget: double.tryParse(_budgetController.text) ?? 0.0,
          currency: _currency,
          isShared: _existingItinerary!.isShared,
          createdAt: _existingItinerary!.createdAt,
          updatedAt: DateTime.now(),
        );
        
        final success = await provider.updateItinerary(updatedItinerary);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Itinerary updated successfully')),
          );
          context.go('/itinerary');
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update itinerary')),
          );
        }
      } else {
        // Create new itinerary
        final newItinerary = provider.createBasicItinerary(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          startDate: _startDate!,
          endDate: _endDate!,
          imageUrl: _imageUrlController.text.trim(),
        );
        
        // Set budget if provided
        final itineraryWithBudget = Itinerary(
          id: newItinerary.id,
          title: newItinerary.title,
          description: newItinerary.description,
          startDate: newItinerary.startDate,
          endDate: newItinerary.endDate,
          days: newItinerary.days,
          imageUrl: newItinerary.imageUrl,
          totalBudget: double.tryParse(_budgetController.text) ?? 0.0,
          currency: _currency,
          isShared: false,
          createdAt: newItinerary.createdAt,
          updatedAt: newItinerary.updatedAt,
        );
        
        final id = await provider.createItinerary(itineraryWithBudget);
        
        if (id != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Itinerary created successfully')),
          );
          context.go('/itinerary');
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create itinerary')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_existingItinerary != null ? 'Edit Itinerary' : 'Create Itinerary'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/itinerary'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Trip Title',
                        hintText: 'e.g., Summer Vacation in Paris',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe your trip...',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    
                    // Start Date
                    InkWell(
                      onTap: _selectStartDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _startDate != null
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                              : 'Select start date',
                          style: TextStyle(
                            color: _startDate != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    
                    // End Date
                    InkWell(
                      onTap: _selectEndDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          prefixIcon: Icon(Icons.event),
                        ),
                        child: Text(
                          _endDate != null
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Select end date',
                          style: TextStyle(
                            color: _endDate != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    
                    // Duration Display
                    if (_startDate != null && _endDate != null)
                      Container(
                        padding: const EdgeInsets.all(AppConstants.paddingSmall),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timelapse,
                              size: 20,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Duration: ${_endDate!.difference(_startDate!).inDays + 1} days',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    
                    // Budget
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _budgetController,
                            decoration: const InputDecoration(
                              labelText: 'Budget (Optional)',
                              hintText: '0.00',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _currency,
                            decoration: const InputDecoration(
                              labelText: 'Currency',
                            ),
                            items: ['USD', 'EUR', 'GBP', 'JPY', 'INR']
                                .map((currency) => DropdownMenuItem(
                                      value: currency,
                                      child: Text(currency),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _currency = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    
                    // Image URL
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL (Optional)',
                        hintText: 'https://example.com/image.jpg',
                        prefixIcon: Icon(Icons.image),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingExtraLarge),
                    
                    // Save Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveItinerary,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.paddingMedium,
                        ),
                      ),
                      child: Text(
                        _existingItinerary != null ? 'Update Itinerary' : 'Create Itinerary',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
