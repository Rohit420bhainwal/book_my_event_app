import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionReceiptScreen extends StatelessWidget {
  const TransactionReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Icon(Icons.flag_outlined, color: Colors.black),
          SizedBox(width: 16),
          Icon(Icons.more_vert, color: Colors.black),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),

            // Circle Profile
            CircleAvatar(
              radius: 38,
              backgroundColor: const Color(0xFF5C6BC0),
              child: Text(
                'R',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'To Riya Gupta',
              style: GoogleFonts.roboto(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24),
            Text(
              '₹299',
              style: GoogleFonts.roboto(
                fontSize: 48,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Completed',
                  style: GoogleFonts.roboto(
                    color: Colors.green[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              '7 Jul 2025, 7:56 pm',
              style: GoogleFonts.roboto(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 28),

            // Bank Details Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bank Header Row
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/hdfc_logo.png',
                          height: 28,
                          width: 28,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'HDFC Bank 7034',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.black54),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _buildDetailText('UPI transaction ID', '107707605810'),
                    _buildDetailText('To: Riya Gupta', 'riyagupta147508.rzp@rxaxis'),
                    _buildDetailText(
                      'From: ROHIT MANOJ BHAINWAL (HDFC Bank)',
                      'Google Pay • rohit.bhainwal40-1@okhdfcbank',
                    ),
                    _buildDetailText(
                      'Google transaction ID',
                      'CICAgKiu0_6GIA',
                    ),

                    const SizedBox(height: 20),

                    // UPI Footer
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'POWERED BY',
                            style: GoogleFonts.roboto(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'UPI',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
