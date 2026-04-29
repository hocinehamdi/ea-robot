import React from 'react';
import { View, Text, StyleSheet, FlatList, StatusBar, Platform, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { ChevronLeft, CheckCircle2, AlertCircle, Clock, Sparkles, RefreshCcw } from 'lucide-react-native';
import { useRobotStore, QueuedCommand } from '@/src/presentation/state/useRobotStore';
import { Colors, Spacing, BorderRadius } from '@/constants/theme';
import { useColorScheme } from '@/hooks/use-color-scheme';
import { router } from 'expo-router';
import { MotiView } from 'moti';

export default function CommandMonitorScreen() {
  const colorScheme = useColorScheme() ?? 'dark';
  const theme = Colors[colorScheme];
  const { commandQueue } = useRobotStore();

  const renderHeader = () => (
    <View style={styles.header}>
      <TouchableOpacity 
        onPress={() => router.back()} 
        style={styles.backButton}
      >
        <ChevronLeft size={24} color="#FFF" />
      </TouchableOpacity>
      
      <View style={styles.headerTextContainer}>
        <Text style={[styles.subTitle, { color: 'rgba(255,255,255,0.4)' }]}>SYSTEM LOGS</Text>
        <Text style={[styles.title, { color: '#FFF' }]}>COMMAND MONITOR</Text>
      </View>

      <View style={[
        styles.statusCircle, 
        { 
          borderColor: commandQueue.length > 0 ? theme.warning || '#F59E0B' : theme.success,
          backgroundColor: commandQueue.length > 0 ? 'rgba(245, 158, 11, 0.1)' : 'rgba(16, 185, 129, 0.1)'
        }
      ]}>
        {commandQueue.length > 0 ? (
          <RefreshCcw size={20} color={theme.warning || '#F59E0B'} />
        ) : (
          <CheckCircle2 size={20} color={theme.success} />
        )}
      </View>
    </View>
  );

  const renderEmptyState = () => (
    <MotiView 
      from={{ opacity: 0, scale: 0.9 }}
      animate={{ opacity: 1, scale: 1 }}
      style={styles.emptyContainer}
    >
      <View style={styles.emptyIconWrapper}>
        <Sparkles size={48} color={theme.tint} />
      </View>
      <Text style={[styles.emptyTitle, { color: '#FFF' }]}>SYSTEM NOMINAL</Text>
      <Text style={[styles.emptySubTitle, { color: 'rgba(255,255,255,0.4)' }]}>All command pipelines are clear</Text>
    </MotiView>
  );

  const renderCommandCard = ({ item, index }: { item: QueuedCommand, index: number }) => {
    const timeStr = item.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
    
    let statusIcon = <Clock size={16} color={theme.warning || '#F59E0B'} />;
    let statusColor = theme.warning || '#F59E0B';
    
    if (item.status === 'success') {
      statusIcon = <CheckCircle2 size={16} color={theme.success} />;
      statusColor = theme.success;
    } else if (item.status === 'failed') {
      statusIcon = <AlertCircle size={16} color={theme.danger} />;
      statusColor = theme.danger;
    } else if (item.status === 'processing') {
      statusIcon = <RefreshCcw size={16} color={theme.tint} />;
      statusColor = theme.tint;
    }

    return (
      <MotiView 
        from={{ opacity: 0, translateX: -20 }}
        animate={{ opacity: 1, translateX: 0 }}
        transition={{ delay: index * 50 }}
        style={[styles.card, { backgroundColor: 'rgba(255,255,255,0.05)', borderColor: 'rgba(255,255,255,0.1)' }]}
      >
        <View style={[styles.statusIndicator, { backgroundColor: `${statusColor}15`, borderColor: `${statusColor}30` }]}>
          {statusIcon}
        </View>
        <View style={styles.cardContent}>
          <View style={styles.cardHeader}>
            <Text style={styles.cardLabel}>{item.label}</Text>
            <Text style={styles.cardTime}>{timeStr}</Text>
          </View>
          <View style={styles.pathContainer}>
            <Text style={styles.methodText}>{item.method}</Text>
            <Text style={styles.cardPath}>{item.path}</Text>
          </View>
        </View>
      </MotiView>
    );
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" />
      <LinearGradient
        colors={theme.gradient || ['#0F2027', '#203A43', '#2C5364']}
        style={StyleSheet.absoluteFill}
      />
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.content}>
          {renderHeader()}
          <FlatList
            data={commandQueue}
            renderItem={renderCommandCard}
            keyExtractor={(item) => item.id}
            ListEmptyComponent={renderEmptyState}
            contentContainerStyle={styles.listContent}
            showsVerticalScrollIndicator={false}
          />
        </View>
      </SafeAreaView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  safeArea: {
    flex: 1,
  },
  content: {
    flex: 1,
    paddingHorizontal: Spacing.lg,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: Spacing.xl,
    paddingVertical: Spacing.md,
    gap: 16,
  },
  backButton: {
    width: 44,
    height: 44,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.05)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.1)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  headerTextContainer: {
    flex: 1,
  },
  title: {
    fontSize: 18,
    fontWeight: '900',
    letterSpacing: 0.5,
  },
  subTitle: {
    fontSize: 10,
    fontWeight: 'bold',
    letterSpacing: 2,
    marginBottom: 2,
  },
  statusCircle: {
    width: 44,
    height: 44,
    borderRadius: 22,
    borderWidth: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  listContent: {
    paddingBottom: Spacing.xl,
  },
  card: {
    flexDirection: 'row',
    padding: 16,
    borderRadius: 20,
    borderWidth: 1,
    marginBottom: 12,
    alignItems: 'center',
  },
  statusIndicator: {
    width: 40,
    height: 40,
    borderRadius: 12,
    borderWidth: 1,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  cardContent: {
    flex: 1,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 6,
  },
  cardLabel: {
    color: '#FFF',
    fontSize: 14,
    fontWeight: '800',
  },
  cardTime: {
    color: 'rgba(255,255,255,0.3)',
    fontSize: 10,
    fontWeight: 'bold',
  },
  pathContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  methodText: {
    color: '#38BDF8',
    fontSize: 9,
    fontWeight: '900',
    backgroundColor: 'rgba(56, 189, 248, 0.1)',
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 4,
  },
  cardPath: {
    color: 'rgba(255,255,255,0.5)',
    fontSize: 11,
    fontFamily: Platform.OS === 'ios' ? 'Menlo' : 'monospace',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 80,
  },
  emptyIconWrapper: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: 'rgba(56, 189, 248, 0.05)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 24,
    borderWidth: 1,
    borderColor: 'rgba(56, 189, 248, 0.1)',
  },
  emptyTitle: {
    fontSize: 16,
    fontWeight: '900',
    letterSpacing: 1,
    marginBottom: 8,
  },
  emptySubTitle: {
    fontSize: 13,
    textAlign: 'center',
  },
});
