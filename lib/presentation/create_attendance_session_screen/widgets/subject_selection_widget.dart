import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class SubjectSelectionWidget extends StatefulWidget {
  final String? selectedSubject;
  final Function(String?) onSubjectChanged;

  const SubjectSelectionWidget({
    super.key,
    this.selectedSubject,
    required this.onSubjectChanged,
  });

  @override
  State<SubjectSelectionWidget> createState() => _SubjectSelectionWidgetState();
}

class _SubjectSelectionWidgetState extends State<SubjectSelectionWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredSubjects = [];
  bool _isDropdownOpen = false;

  // Mock subjects data for faculty
  final List<Map<String, dynamic>> _subjects = [
    {
      "id": "CS101",
      "name": "Data Structures and Algorithms",
      "code": "CS101",
      "credits": 4,
      "semester": "3rd"
    },
    {
      "id": "CS102",
      "name": "Object Oriented Programming",
      "code": "CS102",
      "credits": 3,
      "semester": "3rd"
    },
    {
      "id": "CS201",
      "name": "Database Management Systems",
      "code": "CS201",
      "credits": 4,
      "semester": "4th"
    },
    {
      "id": "CS202",
      "name": "Computer Networks",
      "code": "CS202",
      "credits": 3,
      "semester": "4th"
    },
    {
      "id": "CS301",
      "name": "Software Engineering",
      "code": "CS301",
      "credits": 4,
      "semester": "5th"
    },
    {
      "id": "CS302",
      "name": "Machine Learning",
      "code": "CS302",
      "credits": 3,
      "semester": "5th"
    }
  ];

  @override
  void initState() {
    super.initState();
    _filteredSubjects = _subjects;
    _searchController.addListener(_filterSubjects);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSubjects() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSubjects = _subjects.where((subject) {
        final name = (subject["name"] as String).toLowerCase();
        final code = (subject["code"] as String).toLowerCase();
        return name.contains(query) || code.contains(query);
      }).toList();
    });
  }

  void _selectSubject(Map<String, dynamic> subject) {
    widget.onSubjectChanged(subject["id"] as String);
    setState(() {
      _isDropdownOpen = false;
    });
    _searchController.clear();
  }

  String _getSelectedSubjectName() {
    if (widget.selectedSubject == null) return "Select Subject";
    final subject = _subjects.firstWhere(
      (s) => s["id"] == widget.selectedSubject,
      orElse: () => {"name": "Unknown Subject"},
    );
    return "${subject["code"]} - ${subject["name"]}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject Selection Header
          InkWell(
            onTap: () {
              setState(() {
                _isDropdownOpen = !_isDropdownOpen;
              });
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'book',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Subject",
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _getSelectedSubjectName(),
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: widget.selectedSubject != null
                                ? AppTheme.lightTheme.colorScheme.onSurface
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: _isDropdownOpen
                        ? 'keyboard_arrow_up'
                        : 'keyboard_arrow_down',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Dropdown Content
          if (_isDropdownOpen) ...[
            Divider(
              height: 1,
              color: AppTheme.lightTheme.dividerColor,
            ),

            // Search Field
            Container(
              padding: EdgeInsets.all(3.w),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search subjects...",
                  prefixIcon: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: AppTheme.lightTheme.dividerColor,
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: AppTheme.lightTheme.dividerColor,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: AppTheme.lightTheme.primaryColor,
                      width: 2.0,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                ),
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ),

            // Subject List
            Container(
              constraints: BoxConstraints(maxHeight: 40.h),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredSubjects.length,
                itemBuilder: (context, index) {
                  final subject = _filteredSubjects[index];
                  final isSelected = widget.selectedSubject == subject["id"];

                  return InkWell(
                    onTap: () => _selectSubject(subject),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.primaryColor
                                .withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.primaryColor
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Center(
                              child: Text(
                                subject["code"].toString().substring(0, 2),
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.lightTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${subject["code"]} - ${subject["name"]}",
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? AppTheme.lightTheme.primaryColor
                                        : AppTheme
                                            .lightTheme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  "${subject["credits"]} Credits • ${subject["semester"]} Semester",
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            CustomIconWidget(
                              iconName: 'check_circle',
                              color: AppTheme.lightTheme.primaryColor,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
