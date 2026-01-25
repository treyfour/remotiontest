import React, { useState } from 'react';
import { 
  X, Search, GitBranch, Layout, Brain, Share2, Grid3X3,
  MoreHorizontal, Pencil, Trash2, Copy, ArrowLeft, ChevronRight,
  Upload, Image, Sparkles, Zap, CheckCircle, MapPin, Star
} from 'lucide-react';

const categories = [
  { id: 'all', name: 'All', icon: Grid3X3, color: '#6366f1' },
  { id: 'favorites', name: 'Favorites', icon: Star, color: '#eab308' },
  { id: 'create-new', name: 'Create New', icon: Sparkles, color: '#8b5cf6' },
  { id: 'flowchart', name: 'Flowcharts', icon: GitBranch, color: '#22c55e' },
  { id: 'wireframe', name: 'Wireframes', icon: Layout, color: '#3b82f6' },
  { id: 'mindmap', name: 'Mind Maps', icon: Brain, color: '#f59e0b' },
  { id: 'diagram', name: 'Diagrams', icon: Share2, color: '#ec4899' },
];

const templates = [
  { id: 0, name: 'Draft from example', category: 'reference', creator: 'Excalidraw', description: 'Upload any image—a screenshot, sketch, or design—and we\'ll automatically generate a matching Excalidraw layout. Perfect for quickly recreating diagrams, wireframes, or any visual reference.', isSpecial: true, speedType: 'ai', states: null },
  { id: 1, name: 'Basic Flowchart', category: 'flowchart', creator: 'Excalidraw Team', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', speedType: 'human', states: null },
  { id: 2, name: 'Decision Tree', category: 'flowchart', creator: 'Community', description: 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.', speedType: 'ai', states: null },
  { id: 3, name: 'Process Flow', category: 'flowchart', creator: 'Excalidraw Team', description: 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.', speedType: 'human', states: ['NY', 'NJ'] },
  { id: 4, name: 'User Flow', category: 'flowchart', creator: 'Community', description: 'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.', speedType: 'ai', states: null },
  { id: 5, name: 'Swimlane', category: 'flowchart', creator: 'Excalidraw Team', description: 'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium.', speedType: 'human', states: ['CA', 'TX', 'FL'] },
  { id: 6, name: 'Mobile App', category: 'wireframe', creator: 'Excalidraw Team', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt.', speedType: 'human', states: null },
  { id: 7, name: 'Dashboard', category: 'wireframe', creator: 'Community', description: 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip.', speedType: 'ai', states: ['NY'] },
  { id: 8, name: 'Landing Page', category: 'wireframe', creator: 'Excalidraw Team', description: 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore.', speedType: 'human', states: null },
  { id: 9, name: 'Form Layout', category: 'wireframe', creator: 'Community', description: 'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia.', speedType: 'ai', states: ['NJ', 'PA'] },
  { id: 10, name: 'Navigation', category: 'wireframe', creator: 'Excalidraw Team', description: 'Sed ut perspiciatis unde omnis iste natus error sit voluptatem.', speedType: 'human', states: null },
  { id: 11, name: 'Brainstorm', category: 'mindmap', creator: 'Excalidraw Team', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', speedType: 'human', states: null },
  { id: 12, name: 'Project Planning', category: 'mindmap', creator: 'Community', description: 'Ut enim ad minim veniam, quis nostrud exercitation.', speedType: 'ai', states: ['CA'] },
  { id: 13, name: 'Concept Map', category: 'mindmap', creator: 'Excalidraw Team', description: 'Duis aute irure dolor in reprehenderit in voluptate.', speedType: 'human', states: null },
  { id: 14, name: 'Strategy Map', category: 'mindmap', creator: 'Community', description: 'Excepteur sint occaecat cupidatat non proident.', speedType: 'ai', states: ['NY', 'NJ', 'CT'] },
  { id: 15, name: 'Idea Board', category: 'mindmap', creator: 'Excalidraw Team', description: 'Sed ut perspiciatis unde omnis iste natus.', speedType: 'human', states: null },
  { id: 16, name: 'ER Diagram', category: 'diagram', creator: 'Excalidraw Team', description: 'Lorem ipsum dolor sit amet consectetur.', speedType: 'human', states: null },
  { id: 17, name: 'Network Diagram', category: 'diagram', creator: 'Community', description: 'Ut enim ad minim veniam quis nostrud.', speedType: 'ai', states: null },
  { id: 18, name: 'Sequence Diagram', category: 'diagram', creator: 'Excalidraw Team', description: 'Duis aute irure dolor in reprehenderit.', speedType: 'human', states: ['TX', 'AZ'] },
  { id: 19, name: 'Class Diagram', category: 'diagram', creator: 'Community', description: 'Excepteur sint occaecat cupidatat.', speedType: 'ai', states: null },
  { id: 20, name: 'Architecture', category: 'diagram', creator: 'Excalidraw Team', description: 'Sed ut perspiciatis unde omnis.', speedType: 'human', states: null },
];

// SVG Thumbnail Components for each category
const FlowchartThumbnail = () => (
  <svg viewBox="0 0 120 80" className="w-full h-full">
    <rect x="35" y="5" width="50" height="20" rx="2" fill="#e0e7ff" stroke="#6366f1" strokeWidth="1.5"/>
    <rect x="35" y="35" width="50" height="20" rx="10" fill="#dcfce7" stroke="#22c55e" strokeWidth="1.5"/>
    <rect x="35" y="65" width="50" height="20" rx="2" fill="#e0e7ff" stroke="#6366f1" strokeWidth="1.5"/>
    <line x1="60" y1="25" x2="60" y2="35" stroke="#64748b" strokeWidth="1.5"/>
    <line x1="60" y1="55" x2="60" y2="65" stroke="#64748b" strokeWidth="1.5"/>
    <polygon points="60,33 56,28 64,28" fill="#64748b"/>
    <polygon points="60,63 56,58 64,58" fill="#64748b"/>
  </svg>
);

const WireframeThumbnail = () => (
  <svg viewBox="0 0 120 80" className="w-full h-full">
    <rect x="10" y="5" width="100" height="12" rx="2" fill="#e0e7ff" stroke="#3b82f6" strokeWidth="1.5"/>
    <rect x="10" y="22" width="30" height="50" rx="2" fill="#f1f5f9" stroke="#94a3b8" strokeWidth="1"/>
    <rect x="45" y="22" width="65" height="25" rx="2" fill="#dbeafe" stroke="#3b82f6" strokeWidth="1.5"/>
    <rect x="45" y="52" width="30" height="20" rx="2" fill="#f1f5f9" stroke="#94a3b8" strokeWidth="1"/>
    <rect x="80" y="52" width="30" height="20" rx="2" fill="#f1f5f9" stroke="#94a3b8" strokeWidth="1"/>
  </svg>
);

const MindmapThumbnail = () => (
  <svg viewBox="0 0 120 80" className="w-full h-full">
    <ellipse cx="60" cy="40" rx="20" ry="12" fill="#fef3c7" stroke="#f59e0b" strokeWidth="1.5"/>
    <ellipse cx="20" cy="20" rx="15" ry="10" fill="#fef9c3" stroke="#eab308" strokeWidth="1"/>
    <ellipse cx="100" cy="20" rx="15" ry="10" fill="#fef9c3" stroke="#eab308" strokeWidth="1"/>
    <ellipse cx="20" cy="60" rx="15" ry="10" fill="#fef9c3" stroke="#eab308" strokeWidth="1"/>
    <ellipse cx="100" cy="60" rx="15" ry="10" fill="#fef9c3" stroke="#eab308" strokeWidth="1"/>
    <line x1="42" y1="34" x2="32" y2="26" stroke="#64748b" strokeWidth="1.5"/>
    <line x1="78" y1="34" x2="88" y2="26" stroke="#64748b" strokeWidth="1.5"/>
    <line x1="42" y1="46" x2="32" y2="54" stroke="#64748b" strokeWidth="1.5"/>
    <line x1="78" y1="46" x2="88" y2="54" stroke="#64748b" strokeWidth="1.5"/>
  </svg>
);

const DiagramThumbnail = () => (
  <svg viewBox="0 0 120 80" className="w-full h-full">
    <rect x="10" y="10" width="35" height="25" rx="2" fill="#fce7f3" stroke="#ec4899" strokeWidth="1.5"/>
    <rect x="75" y="10" width="35" height="25" rx="2" fill="#fce7f3" stroke="#ec4899" strokeWidth="1.5"/>
    <rect x="10" y="50" width="35" height="25" rx="2" fill="#fce7f3" stroke="#ec4899" strokeWidth="1.5"/>
    <rect x="75" y="50" width="35" height="25" rx="2" fill="#fce7f3" stroke="#ec4899" strokeWidth="1.5"/>
    <line x1="45" y1="22" x2="75" y2="22" stroke="#64748b" strokeWidth="1.5"/>
    <line x1="27" y1="35" x2="27" y2="50" stroke="#64748b" strokeWidth="1.5"/>
    <line x1="92" y1="35" x2="92" y2="50" stroke="#64748b" strokeWidth="1.5"/>
    <line x1="45" y1="62" x2="75" y2="62" stroke="#64748b" strokeWidth="1.5"/>
  </svg>
);

const getThumbnail = (category) => {
  switch (category) {
    case 'flowchart': return <FlowchartThumbnail />;
    case 'wireframe': return <WireframeThumbnail />;
    case 'mindmap': return <MindmapThumbnail />;
    case 'diagram': return <DiagramThumbnail />;
    default: return <FlowchartThumbnail />;
  }
};

const getCategoryInfo = (categoryId) => categories.find(c => c.id === categoryId) || categories[0];

// Mock user's state - in production this would come from user profile/settings
const USER_STATE = 'NY';

// Speed type badge component
const SpeedBadge = ({ type }) => {
  if (type === 'ai') {
    return (
      <span className="inline-flex items-center gap-1 text-xs font-medium px-1.5 py-0.5 rounded-full bg-amber-100 text-amber-700">
        <Zap size={10} />
      </span>
    );
  }
  return (
    <span className="inline-flex items-center gap-1 text-xs font-medium px-1.5 py-0.5 rounded-full bg-emerald-100 text-emerald-700">
      <CheckCircle size={10} />
    </span>
  );
};

// Dropdown Menu Component
const DropdownMenu = ({ isOpen, onClose, onRename, onDuplicate, onDelete }) => {
  if (!isOpen) return null;
  
  return (
    <>
      <div className="fixed inset-0 z-40" onClick={onClose} />
      <div className="absolute right-0 top-8 z-50 bg-white rounded-lg shadow-lg border border-gray-200 py-1 min-w-[140px]">
        <button 
          onClick={onRename}
          className="w-full px-3 py-2 text-left text-sm text-gray-700 hover:bg-gray-50 flex items-center gap-2"
        >
          <Pencil size={14} /> Rename
        </button>
        <button 
          onClick={onDuplicate}
          className="w-full px-3 py-2 text-left text-sm text-gray-700 hover:bg-gray-50 flex items-center gap-2"
        >
          <Copy size={14} /> Duplicate
        </button>
        <button 
          onClick={onDelete}
          className="w-full px-3 py-2 text-left text-sm text-red-600 hover:bg-red-50 flex items-center gap-2"
        >
          <Trash2 size={14} /> Delete
        </button>
      </div>
    </>
  );
};

// Special Reference Upload Card Component
const ReferenceCard = ({ template, onClick }) => {
  const [isHovered, setIsHovered] = useState(false);

  return (
    <div 
      className="relative bg-gradient-to-br from-violet-50 to-indigo-50 rounded-xl border-2 border-dashed border-violet-300 overflow-hidden cursor-pointer transition-all duration-200 hover:shadow-lg hover:border-violet-400 hover:-translate-y-1"
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      onClick={() => onClick(template)}
    >
      {/* Thumbnail - Upload to Magic Document */}
      <div className="relative h-32 flex items-center justify-center px-4">
        <svg viewBox="0 0 200 80" className="w-full h-full">
          {/* Left side - Upload/Source document */}
          <g>
            {/* Document outline */}
            <rect x="15" y="12" width="45" height="56" rx="4" fill="#f8fafc" stroke="#94a3b8" strokeWidth="1.5" strokeDasharray="3 2"/>
            {/* Image icon inside */}
            <rect x="22" y="22" width="31" height="22" rx="2" fill="#e2e8f0"/>
            <circle cx="29" cy="30" r="4" fill="#94a3b8"/>
            <path d="M24 40 L32 32 L38 38 L44 30 L51 40 Z" fill="#94a3b8"/>
            {/* Lines representing content */}
            <rect x="22" y="48" width="31" height="3" rx="1" fill="#cbd5e1"/>
            <rect x="22" y="54" width="20" height="3" rx="1" fill="#cbd5e1"/>
          </g>
          
          {/* Middle - Magic transformation arrow */}
          <g>
            {/* Sparkle particles */}
            <circle cx="85" cy="25" r="2" fill="#a78bfa">
              <animate attributeName="opacity" values="1;0.3;1" dur="1.5s" repeatCount="indefinite"/>
            </circle>
            <circle cx="95" cy="55" r="1.5" fill="#818cf8">
              <animate attributeName="opacity" values="0.3;1;0.3" dur="1.5s" repeatCount="indefinite"/>
            </circle>
            <circle cx="115" cy="30" r="1.5" fill="#c4b5fd">
              <animate attributeName="opacity" values="0.5;1;0.5" dur="1.2s" repeatCount="indefinite"/>
            </circle>
            
            {/* Arrow with gradient */}
            <defs>
              <linearGradient id="arrowGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                <stop offset="0%" stopColor="#a78bfa"/>
                <stop offset="100%" stopColor="#6366f1"/>
              </linearGradient>
            </defs>
            <path d="M75 40 L115 40" stroke="url(#arrowGradient)" strokeWidth="2.5" strokeLinecap="round"/>
            <path d="M108 33 L118 40 L108 47" stroke="url(#arrowGradient)" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" fill="none"/>
            
            {/* Sparkle icon in middle */}
            <g transform="translate(92, 36)">
              <path d="M4 0 L5 3 L8 4 L5 5 L4 8 L3 5 L0 4 L3 3 Z" fill="#8b5cf6">
                <animate attributeName="transform" attributeType="XML" type="rotate" from="0 4 4" to="360 4 4" dur="4s" repeatCount="indefinite"/>
              </path>
            </g>
          </g>
          
          {/* Right side - Styled Excalidraw document */}
          <g>
            {/* Document outline - polished */}
            <rect x="130" y="12" width="55" height="56" rx="4" fill="white" stroke="#6366f1" strokeWidth="2"/>
            
            {/* Mini flowchart inside */}
            <rect x="145" y="18" width="24" height="10" rx="2" fill="#e0e7ff" stroke="#6366f1" strokeWidth="1"/>
            <rect x="145" y="36" width="24" height="10" rx="5" fill="#dcfce7" stroke="#22c55e" strokeWidth="1"/>
            <rect x="145" y="54" width="24" height="10" rx="2" fill="#e0e7ff" stroke="#6366f1" strokeWidth="1"/>
            
            {/* Connecting lines */}
            <line x1="157" y1="28" x2="157" y2="36" stroke="#64748b" strokeWidth="1"/>
            <line x1="157" y1="46" x2="157" y2="54" stroke="#64748b" strokeWidth="1"/>
            
            {/* Small arrows */}
            <polygon points="157,34 155,31 159,31" fill="#64748b"/>
            <polygon points="157,52 155,49 159,49" fill="#64748b"/>
          </g>
        </svg>
        
        {/* Hover overlay */}
        <div className={`absolute inset-0 bg-violet-500/5 flex items-center justify-center transition-opacity duration-200 ${isHovered ? 'opacity-100' : 'opacity-0'}`}>
          <span className="bg-white/90 backdrop-blur-sm text-violet-600 text-sm font-medium px-3 py-1.5 rounded-full shadow-sm flex items-center gap-1">
            Get started <ChevronRight size={14} />
          </span>
        </div>
      </div>
      
      {/* Content */}
      <div className="p-3 bg-white/50">
        {/* Special tag + Speed badge */}
        <div className="flex items-center gap-1.5 mb-2">
          <span className="inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-full bg-violet-100 text-violet-600">
            <Sparkles size={10} />
            New
          </span>
          {template.speedType && <SpeedBadge type={template.speedType} />}
        </div>
        
        {/* Title & Creator */}
        <div className="min-w-0">
          <h3 className="font-medium text-gray-900 text-sm">{template.name}</h3>
          <p className="text-xs text-gray-500 mt-0.5">{template.creator}</p>
        </div>
      </div>
    </div>
  );
};

// Template Card Component
const TemplateCard = ({ template, onClick, onMenuAction, isAvailable = true, isFavorite = false, onToggleFavorite }) => {
  const [menuOpen, setMenuOpen] = useState(false);
  const [isHovered, setIsHovered] = useState(false);
  const categoryInfo = getCategoryInfo(template.category);
  const CategoryIcon = categoryInfo.icon;

  return (
    <div 
      className={`relative bg-white rounded-xl border overflow-hidden transition-all duration-200 ${
        isAvailable 
          ? 'border-gray-200 cursor-pointer hover:shadow-lg hover:border-gray-300 hover:-translate-y-1' 
          : 'border-gray-200 opacity-50 cursor-not-allowed'
      }`}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      onClick={() => isAvailable && !menuOpen && onClick(template)}
    >
      {/* Thumbnail */}
      <div className="relative h-32 bg-gradient-to-br from-gray-50 to-gray-100 p-4 flex items-center justify-center">
        {getThumbnail(template.category)}
        
        {/* Star button - top right */}
        <button
          onClick={(e) => onToggleFavorite(template.id, e)}
          className={`absolute top-2 right-2 p-1.5 rounded-lg transition-all duration-200 ${
            isFavorite 
              ? 'bg-yellow-100 text-yellow-500' 
              : 'bg-white/80 text-gray-400 opacity-0 hover:text-yellow-500'
          } ${isHovered || isFavorite ? 'opacity-100' : ''}`}
        >
          <Star size={16} fill={isFavorite ? 'currentColor' : 'none'} />
        </button>
        
        {/* Hover overlay */}
        {isAvailable ? (
          <div className={`absolute inset-0 bg-black/5 flex items-center justify-center transition-opacity duration-200 pointer-events-none ${isHovered ? 'opacity-100' : 'opacity-0'}`}>
            <span className="bg-white/90 backdrop-blur-sm text-gray-700 text-sm font-medium px-3 py-1.5 rounded-full shadow-sm flex items-center gap-1">
              Preview <ChevronRight size={14} />
            </span>
          </div>
        ) : (
          <div className={`absolute inset-0 bg-gray-100/50 flex items-center justify-center transition-opacity duration-200 pointer-events-none ${isHovered ? 'opacity-100' : 'opacity-0'}`}>
            <span className="bg-white/90 backdrop-blur-sm text-gray-500 text-sm font-medium px-3 py-1.5 rounded-full shadow-sm flex items-center gap-1">
              <MapPin size={12} /> Not in {USER_STATE}
            </span>
          </div>
        )}
      </div>
      
      {/* Content */}
      <div className="p-3">
        {/* Category tag + Speed badge + State restriction */}
        <div className="flex items-center gap-1.5 mb-2 flex-wrap">
          <span 
            className="inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-full"
            style={{ 
              backgroundColor: `${categoryInfo.color}15`,
              color: categoryInfo.color 
            }}
          >
            <CategoryIcon size={10} />
            {categoryInfo.name}
          </span>
          {template.speedType && <SpeedBadge type={template.speedType} />}
          {template.states && (
            <span className="inline-flex items-center gap-1 text-xs font-medium px-1.5 py-0.5 rounded-full bg-gray-100 text-gray-600">
              <MapPin size={10} />
              {template.states.join(', ')}
            </span>
          )}
        </div>
        
        {/* Title & Creator */}
        <div className="flex items-start justify-between gap-2">
          <div className="min-w-0">
            <h3 className="font-medium text-gray-900 text-sm truncate">{template.name}</h3>
            <p className="text-xs text-gray-500 mt-0.5">{template.creator}</p>
          </div>
          
          {/* Menu button */}
          <button 
            onClick={(e) => { e.stopPropagation(); setMenuOpen(!menuOpen); }}
            className="p-1 hover:bg-gray-100 rounded-md transition-colors flex-shrink-0"
          >
            <MoreHorizontal size={16} className="text-gray-400" />
          </button>
        </div>
      </div>
      
      {/* Dropdown Menu */}
      <DropdownMenu 
        isOpen={menuOpen} 
        onClose={() => setMenuOpen(false)}
        onRename={() => { onMenuAction('rename', template); setMenuOpen(false); }}
        onDuplicate={() => { onMenuAction('duplicate', template); setMenuOpen(false); }}
        onDelete={() => { onMenuAction('delete', template); setMenuOpen(false); }}
      />
    </div>
  );
};

// Reference Upload Dialog Component
const ReferenceUploadDialog = ({ template, onBack }) => {
  const [isDragging, setIsDragging] = useState(false);

  const handleDragOver = (e) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = () => {
    setIsDragging(false);
  };

  const handleDrop = (e) => {
    e.preventDefault();
    setIsDragging(false);
    // Handle file drop - placeholder
    console.log('File dropped');
  };

  return (
    <div className="flex flex-col h-full">
      {/* Header */}
      <div className="flex items-center gap-3 px-6 py-4 border-b border-gray-200">
        <button 
          onClick={onBack}
          className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
        >
          <ArrowLeft size={20} className="text-gray-600" />
        </button>
        <h2 className="text-lg font-semibold text-gray-900">{template.name}</h2>
      </div>
      
      {/* Content */}
      <div className="flex-1 p-6 overflow-auto">
        <div className="max-w-2xl mx-auto">
          {/* Educational Content */}
          <div className="mb-6 text-center">
            <div className="inline-flex items-center justify-center w-16 h-16 bg-indigo-100 rounded-full mb-4">
              <Sparkles size={32} className="text-indigo-500" />
            </div>
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Create from any image</h3>
            <p className="text-gray-600 leading-relaxed max-w-md mx-auto">
              {template.description}
            </p>
          </div>
          
          {/* Upload Dropzone */}
          <div 
            className={`relative border-2 border-dashed rounded-xl p-8 text-center transition-all duration-200 ${
              isDragging 
                ? 'border-indigo-500 bg-indigo-50' 
                : 'border-gray-300 bg-gray-50 hover:border-gray-400 hover:bg-gray-100'
            }`}
            onDragOver={handleDragOver}
            onDragLeave={handleDragLeave}
            onDrop={handleDrop}
          >
            <div className="flex flex-col items-center gap-4">
              <div className={`w-16 h-16 rounded-full flex items-center justify-center transition-colors ${
                isDragging ? 'bg-indigo-200' : 'bg-gray-200'
              }`}>
                <Upload size={28} className={isDragging ? 'text-indigo-600' : 'text-gray-500'} />
              </div>
              
              <div>
                <p className="text-gray-700 font-medium mb-1">
                  Drop your image here, or{' '}
                  <button className="text-indigo-600 hover:text-indigo-700 font-medium">
                    browse
                  </button>
                </p>
                <p className="text-sm text-gray-500">
                  Supports PNG, JPG, PDF, or paste from clipboard
                </p>
              </div>
            </div>
          </div>
          
          {/* Tips */}
          <div className="mt-6 p-4 bg-amber-50 rounded-xl border border-amber-200">
            <p className="text-sm text-amber-800">
              <span className="font-medium">💡 Tip:</span> For best results, use clear images with visible shapes, text, and structure. Screenshots of diagrams, wireframes, or hand-drawn sketches work great!
            </p>
          </div>
        </div>
      </div>
      
      {/* Footer */}
      <div className="px-6 py-4 border-t border-gray-200 flex justify-end gap-3">
        <button 
          onClick={onBack}
          className="px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 rounded-lg transition-colors"
        >
          Back
        </button>
      </div>
    </div>
  );
};

// Confirmation Dialog Component
const ConfirmationDialog = ({ template, onConfirm, onBack }) => {
  const categoryInfo = getCategoryInfo(template.category);
  const CategoryIcon = categoryInfo.icon;

  return (
    <div className="flex flex-col h-full">
      {/* Header */}
      <div className="flex items-center gap-3 px-6 py-4 border-b border-gray-200">
        <button 
          onClick={onBack}
          className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
        >
          <ArrowLeft size={20} className="text-gray-600" />
        </button>
        <h2 className="text-lg font-semibold text-gray-900">Template Preview</h2>
      </div>
      
      {/* Content */}
      <div className="flex-1 p-6 overflow-auto">
        <div className="max-w-2xl mx-auto">
          {/* Large Preview */}
          <div className="bg-gradient-to-br from-gray-50 to-gray-100 rounded-xl border border-gray-200 h-64 flex items-center justify-center mb-6">
            <div className="w-3/4 h-3/4">
              {getThumbnail(template.category)}
            </div>
          </div>
          
          {/* Template Info */}
          <div className="space-y-4">
            <div className="flex items-center gap-2 flex-wrap">
              <span 
                className="inline-flex items-center gap-1.5 text-sm font-medium px-3 py-1 rounded-full"
                style={{ 
                  backgroundColor: `${categoryInfo.color}15`,
                  color: categoryInfo.color 
                }}
              >
                <CategoryIcon size={14} />
                {categoryInfo.name}
              </span>
              {template.speedType && (
                <span className={`inline-flex items-center gap-1 text-xs font-medium px-2 py-1 rounded-full ${
                  template.speedType === 'ai' 
                    ? 'bg-amber-100 text-amber-700' 
                    : 'bg-emerald-100 text-emerald-700'
                }`}>
                  {template.speedType === 'ai' ? <Zap size={12} /> : <CheckCircle size={12} />}
                  {template.speedType === 'ai' ? 'AI Generated' : 'Human Curated'}
                </span>
              )}
              {template.states && (
                <span className="inline-flex items-center gap-1 text-xs font-medium px-2 py-1 rounded-full bg-gray-100 text-gray-600">
                  <MapPin size={12} />
                  {template.states.join(', ')} only
                </span>
              )}
            </div>
            
            <h3 className="text-2xl font-semibold text-gray-900">{template.name}</h3>
            <p className="text-sm text-gray-500">Created by {template.creator}</p>
            <p className="text-gray-600 leading-relaxed">{template.description}</p>
          </div>
        </div>
      </div>
      
      {/* Footer */}
      <div className="px-6 py-4 border-t border-gray-200 flex justify-end gap-3">
        <button 
          onClick={onBack}
          className="px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 rounded-lg transition-colors"
        >
          Back
        </button>
        <button 
          onClick={() => onConfirm(template)}
          className="px-4 py-2 text-sm font-medium text-white bg-indigo-500 hover:bg-indigo-600 rounded-lg transition-colors"
        >
          Use Template
        </button>
      </div>
    </div>
  );
};

// Main Template Modal Component
const TemplateModal = ({ isOpen, onClose }) => {
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedTemplate, setSelectedTemplate] = useState(null);
  const [filterByState, setFilterByState] = useState(true);
  const [favorites, setFavorites] = useState(new Set([1, 6, 11])); // Mock some initial favorites

  const toggleFavorite = (templateId, e) => {
    e.stopPropagation();
    setFavorites(prev => {
      const newFavorites = new Set(prev);
      if (newFavorites.has(templateId)) {
        newFavorites.delete(templateId);
      } else {
        newFavorites.add(templateId);
      }
      return newFavorites;
    });
  };

  const filteredTemplates = templates.filter(t => {
    // Check state availability (null means all states)
    // When filterByState is true, hide templates not in user's state
    // When filterByState is false, show all templates
    if (filterByState && t.states && !t.states.includes(USER_STATE)) {
      return false;
    }
    
    // Special reference card shows in "create-new" and "all" views
    if (t.isSpecial) {
      const showInCategory = selectedCategory === 'all' || selectedCategory === 'create-new';
      const matchesSearch = searchQuery === '' || t.name.toLowerCase().includes(searchQuery.toLowerCase());
      return showInCategory && matchesSearch;
    }
    
    // Favorites category
    if (selectedCategory === 'favorites') {
      const isFavorite = favorites.has(t.id);
      const matchesSearch = t.name.toLowerCase().includes(searchQuery.toLowerCase());
      return isFavorite && matchesSearch;
    }
    
    // Regular templates don't show in "create-new" category
    if (selectedCategory === 'create-new') {
      return false;
    }
    const matchesCategory = selectedCategory === 'all' || t.category === selectedCategory;
    const matchesSearch = t.name.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });
  
  // Mark templates as unavailable in user's state (for visual treatment when showing all)
  const templatesWithAvailability = filteredTemplates.map(t => ({
    ...t,
    isAvailableInState: !t.states || t.states.includes(USER_STATE)
  }));

  const handleMenuAction = (action, template) => {
    console.log(`${action} template:`, template.name);
    // Handle actions here
  };

  const handleUseTemplate = (template) => {
    console.log('Using template:', template.name);
    onClose();
  };

  if (!isOpen) return null;

  return (
    <>
      {/* Backdrop */}
      <div 
        className="fixed inset-0 bg-black/30 z-50 transition-opacity"
        onClick={onClose}
      />
      
      {/* Modal */}
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4 pointer-events-none">
        <div 
          className="bg-white rounded-2xl shadow-2xl w-full max-w-4xl pointer-events-auto animate-scale-in"
          style={{ height: '600px' }}
          onClick={(e) => e.stopPropagation()}
        >
          {selectedTemplate ? (
            selectedTemplate.isSpecial ? (
              <ReferenceUploadDialog 
                template={selectedTemplate}
                onBack={() => setSelectedTemplate(null)}
              />
            ) : (
              <ConfirmationDialog 
                template={selectedTemplate}
                onConfirm={handleUseTemplate}
                onBack={() => setSelectedTemplate(null)}
              />
            )
          ) : (
            <div className="h-full flex flex-col">
              {/* Header */}
              <div className="flex items-center justify-between px-6 py-4 border-b border-gray-200">
                <h2 className="text-lg font-semibold text-gray-900">Templates</h2>
                <button 
                  onClick={onClose}
                  className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                >
                  <X size={20} className="text-gray-500" />
                </button>
              </div>
              
              {/* Search & Filters */}
              <div className="px-6 py-4 space-y-4 border-b border-gray-100">
                {/* Search + State indicator */}
                <div className="flex gap-3">
                  <div className="relative flex-1">
                    <Search size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
                    <input
                      type="text"
                      placeholder="Search templates..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="w-full pl-10 pr-4 py-2.5 text-sm bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all"
                    />
                  </div>
                  
                  {/* State indicator + toggle */}
                  <div className="flex items-center gap-2">
                    <span className="inline-flex items-center gap-1.5 px-3 py-2 bg-gray-100 rounded-xl text-sm font-medium text-gray-700">
                      <MapPin size={14} className="text-gray-500" />
                      {USER_STATE}
                    </span>
                    <button
                      onClick={() => setFilterByState(!filterByState)}
                      className={`px-3 py-2 text-sm font-medium rounded-xl transition-all ${
                        filterByState
                          ? 'bg-indigo-100 text-indigo-700 border border-indigo-200'
                          : 'bg-gray-50 text-gray-600 border border-gray-200 hover:bg-gray-100'
                      }`}
                    >
                      {filterByState ? 'My state only' : 'All states'}
                    </button>
                  </div>
                </div>
                
                {/* Category Pills */}
                <div className="flex gap-2 overflow-x-auto pb-1">
                  {categories.map((category) => {
                    const Icon = category.icon;
                    const isActive = selectedCategory === category.id;
                    return (
                      <button
                        key={category.id}
                        onClick={() => setSelectedCategory(category.id)}
                        className={`inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium rounded-full whitespace-nowrap transition-all ${
                          isActive 
                            ? 'text-white shadow-md' 
                            : 'text-gray-600 bg-gray-100 hover:bg-gray-200'
                        }`}
                        style={isActive ? { backgroundColor: category.color } : {}}
                      >
                        <Icon size={14} />
                        {category.name}
                      </button>
                    );
                  })}
                </div>
              </div>
              
              {/* Template Grid - Scrollable Area */}
              <div className="flex-1 overflow-auto p-6">
                {templatesWithAvailability.length > 0 ? (
                  <div className="grid grid-cols-3 gap-4">
                    {templatesWithAvailability.map((template) => (
                      template.isSpecial ? (
                        <ReferenceCard 
                          key={template.id}
                          template={template}
                          onClick={setSelectedTemplate}
                        />
                      ) : (
                        <TemplateCard 
                          key={template.id}
                          template={template}
                          onClick={setSelectedTemplate}
                          onMenuAction={handleMenuAction}
                          isAvailable={template.isAvailableInState}
                          isFavorite={favorites.has(template.id)}
                          onToggleFavorite={toggleFavorite}
                        />
                      )
                    ))}
                  </div>
                ) : (
                  <div className="flex flex-col items-center justify-center h-full text-gray-500">
                    {selectedCategory === 'favorites' ? (
                      <>
                        <Star size={48} className="mb-4 opacity-30" />
                        <p className="text-lg font-medium">No favorites yet</p>
                        <p className="text-sm">Star templates to add them here</p>
                      </>
                    ) : (
                      <>
                        <Search size={48} className="mb-4 opacity-30" />
                        <p className="text-lg font-medium">No templates found</p>
                        <p className="text-sm">Try adjusting your search or filter</p>
                      </>
                    )}
                  </div>
                )}
              </div>
            </div>
          )}
        </div>
      </div>
      
      <style jsx global>{`
        @keyframes scale-in {
          from {
            opacity: 0;
            transform: scale(0.95);
          }
          to {
            opacity: 1;
            transform: scale(1);
          }
        }
        .animate-scale-in {
          animation: scale-in 0.2s ease-out;
        }
      `}</style>
    </>
  );
};

// Demo App
export default function App() {
  const [isModalOpen, setIsModalOpen] = useState(false);

  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center">
      {/* Simulated Excalidraw Canvas */}
      <div className="absolute inset-0 bg-white">
        <div className="absolute inset-0" style={{
          backgroundImage: 'radial-gradient(circle, #e5e7eb 1px, transparent 1px)',
          backgroundSize: '20px 20px'
        }} />
      </div>
      
      {/* Top Toolbar (simplified) */}
      <div className="fixed top-4 left-1/2 -translate-x-1/2 bg-white rounded-xl shadow-lg border border-gray-200 px-2 py-2 flex items-center gap-1 z-10">
        <button className="p-2 hover:bg-gray-100 rounded-lg">
          <Layout size={20} className="text-gray-600" />
        </button>
        <div className="w-px h-6 bg-gray-200 mx-1" />
        <button 
          onClick={() => setIsModalOpen(true)}
          className="px-3 py-2 text-sm font-medium text-indigo-600 hover:bg-indigo-50 rounded-lg transition-colors flex items-center gap-1.5"
        >
          <Grid3X3 size={16} />
          Templates
        </button>
      </div>
      
      {/* Template Modal */}
      <TemplateModal 
        isOpen={isModalOpen} 
        onClose={() => setIsModalOpen(false)} 
      />
      
      {/* Hint Text */}
      {!isModalOpen && (
        <div className="z-10 text-center">
          <p className="text-gray-500 text-sm mb-2">Click the button above to open</p>
          <button 
            onClick={() => setIsModalOpen(true)}
            className="px-6 py-3 bg-indigo-500 text-white font-medium rounded-xl shadow-lg hover:bg-indigo-600 transition-colors"
          >
            Open Templates
          </button>
        </div>
      )}
    </div>
  );
}