import React, { useEffect, useRef } from 'react';
import { Html5Qrcode } from 'html5-qrcode';
import { X } from 'lucide-react';

interface BarcodeScannerProps {
  onScanSuccess: (decodedText: string) => void;
  onClose: () => void;
}

const BarcodeScanner: React.FC<BarcodeScannerProps> = ({ onScanSuccess, onClose }) => {
  const scannerRef = useRef<Html5Qrcode | null>(null);

  useEffect(() => {
    const config = {
      fps: 10,
      qrbox: { width: 250, height: 250 },
      rememberLastUsedCamera: true,
      supportedScanTypes: [0 /* SCAN_TYPE_CAMERA */]
    };

    const html5Qrcode = new Html5Qrcode("reader");
    scannerRef.current = html5Qrcode;
    
    const startScanner = async () => {
        try {
            await html5Qrcode.start(
                { facingMode: "environment" },
                config,
                (decodedText, decodedResult) => {
                    html5Qrcode.stop().then(() => {
                        onScanSuccess(decodedText);
                    }).catch(err => console.error("Failed to stop scanner", err));
                },
                (errorMessage) => {
                    // handle scan error, usually ignore
                }
            );
        } catch (err) {
            console.error("Unable to start scanner", err);
            alert("Could not start camera. Please ensure permissions are granted.");
            onClose();
        }
    };

    startScanner();

    return () => {
      if (scannerRef.current && scannerRef.current.isScanning) {
        scannerRef.current.stop()
          .catch(err => console.error("Failed to stop scanner on cleanup", err));
      }
    };
  }, [onScanSuccess, onClose]);

  return (
    <div className="fixed inset-0 bg-black/80 z-50 flex flex-col items-center justify-center">
      <div id="reader" className="w-full max-w-md bg-black" style={{ aspectRatio: '1 / 1' }}></div>
      <button
        onClick={onClose}
        className="mt-4 px-4 py-2 bg-white text-black rounded-lg font-semibold flex items-center"
      >
        <X size={20} className="mr-2" />
        Cancel
      </button>
    </div>
  );
};

export default BarcodeScanner;