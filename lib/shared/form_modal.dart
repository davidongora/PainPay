import 'package:flutter/material.dart';
import 'package:pain_pay/shared/buttons.dart';

class ReusableFormModal extends StatefulWidget {
  final String title;
  final String description;
  final Map<String, dynamic> fields;
  final String buttonText;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback? onClose;
  final VoidCallback? onButtonAction;

  const ReusableFormModal({
    Key? key,
    required this.title,
    required this.description,
    required this.fields,
    required this.buttonText,
    required this.onSubmit,
    this.onClose,
    this.onButtonAction,
  }) : super(key: key);

  @override
  State<ReusableFormModal> createState() => _ReusableFormModalState();
}

class _ReusableFormModalState extends State<ReusableFormModal> {
  final Map<String, dynamic> _formValues = {};

  @override
  void initState() {
    super.initState();
    widget.fields.forEach((key, value) {
      _formValues[key] = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      // backgroundColor: theme.o,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ...widget.fields.entries.map((entry) {
                final fieldName = entry.key;
                final fieldProperties = entry.value as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: fieldProperties['type'] == 'dropdown'
                      ? _buildDropdownField(
                          fieldName,
                          fieldProperties,
                          theme,
                          colorScheme,
                        )
                      : _buildTextField(
                          fieldName,
                          fieldProperties,
                          theme,
                          colorScheme,
                        ),
                );
              }).toList(),
              const SizedBox(height: 24),
              AppButton(
                text: widget.buttonText,
                onPressed: () {
                  widget.onSubmit(_formValues);
                  if (widget.onButtonAction != null) {
                    widget.onButtonAction!();
                  } else {
                    if (widget.onClose != null) {
                      widget.onClose!();
                    } else {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String fieldName,
    Map<String, dynamic> properties,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: fieldName,
        labelStyle: TextStyle(color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      dropdownColor: colorScheme.surface,
      value: _formValues[fieldName].isNotEmpty ? _formValues[fieldName] : null,
      items: (properties['options'] as List<String>)
          .map(
            (option) => DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _formValues[fieldName] = value;
        });
      },
      icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
    );
  }

  Widget _buildTextField(
    String fieldName,
    Map<String, dynamic> properties,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: fieldName,
        hintText: properties['hintText'],
        labelStyle: TextStyle(color: colorScheme.primary),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      keyboardType: properties['type'] == 'integer'
          ? TextInputType.number
          : TextInputType.text,
      cursorColor: colorScheme.primary,
      onChanged: (value) {
        setState(() {
          _formValues[fieldName] = value;
        });
      },
    );
  }
}
